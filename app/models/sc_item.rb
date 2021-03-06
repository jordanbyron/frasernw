require 'uri'

class ScItem < ActiveRecord::Base
  include Noteable
  include Historical
  include Feedbackable
  include PaperTrailable
  include DivisionAdministered

  include ApplicationHelper

  attr_accessible :sc_category_id,
    :specialization_ids,
    :type_mask,
    :title,
    :searchable,
    :shared_care,
    :url,
    :markdown_content,
    :document,
    :can_email,
    :borrowable,
    :division_id,
    :evidence_id,
    :demoable

  belongs_to :sc_category

  has_many :sc_item_specializations, dependent: :destroy
  has_many :specializations, through: :sc_item_specializations

  has_many :sc_item_specialization_procedure_specializations,
    through: :sc_item_specializations
  has_many :procedure_specializations,
    through: :sc_item_specialization_procedure_specializations

  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :favoriting_users,
    through: :favorites,
    source: :user,
    class_name: "User"

  belongs_to :division

  has_many :featured_contents, dependent: :destroy

  has_many :division_display_sc_items, dependent: :destroy
  has_many :divisions_borrowing,
    through: :division_display_sc_items,
    class_name: "Division",
    source: :division

  belongs_to :evidence

  has_attached_file :document,
    storage: :s3,
    s3_protocol: :https,
    bucket: Pathways::S3.switchable_bucket_name(:content_item_documents),
    s3_credentials: {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  }
  validates_attachment_content_type :document,
    content_type: [
      /\Aimage\/.*\Z/,
      "application/pdf",
      "text/html",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ]

  validates_presence_of :title, on: :create, message: "can't be blank"
  validates :url, url: true, allow_blank: true

  default_scope { order('sc_items.title') }

  def self.demoable
    where(demoable: true)
  end

  def self.provincial
    where(division_id: 13)
  end

  def self.borrowable_by_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where(
      '"sc_items"."division_id" in (?) AND "sc_items"."borrowable" = (?)',
      division_ids, true
    )
  end

  def self.borrowable
    where('"sc_items"."borrowable" = (?)', true)
  end

  def self.owned_by_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where('"sc_items"."division_id" IN (?)', division_ids)
  end

  def self.borrowed_by_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(
      'INNER JOIN "division_display_sc_items" '\
        'ON "division_display_sc_items"."sc_item_id" = "sc_items"."id"'
    ).where(
      '"division_display_sc_items"."division_id" in (?) '\
        'AND "sc_items"."borrowable" = (?)',
      division_ids,
      true
    )
  end

  def self.all_in_divisions(divisions)
    (owned_by_divisions(divisions) + borrowed_by_divisions(divisions)).uniq
  end

  def self.searchable
    where("sc_items.searchable = (?)", true)
  end

  def self.link
    where("sc_items.type_mask = (?)", TYPE_LINK)
  end

  def self.markdown
    where("sc_items.type_mask = (?)", TYPE_MARKDOWN)
  end

  def self.document
    where("sc_items.type_mask = (?)", TYPE_DOCUMENT)
  end

  def self.includes_specialization_data
    includes(sc_item_specializations: [
      :specialization,
      { procedure_specializations: :procedure },
    ])
  end

  def available_to_divisions
    if borrowable
      [ division ] | divisions_borrowing
    else
      [ division ]
    end
  end

  def available_to_divisions?(divisions)
    (
      (divisions.include? division) || (
        borrowable? && (divisions & divisions_borrowing).present?
      )
    )
  end

  def borrowable_by_divisions
    @borrowable_by_divisions ||= begin
      if !borrowable
        []
      else
        Division.all - available_to_divisions
      end
    end
  end

  def mail_to_patient(current_user, patient_email)
    # DO NOT delay: we don't want patient emails in the delayed_jobs table
    MailToPatientMailer.
      mail_to_patient(self, current_user, patient_email).deliver
  end

  def divisions
    [ division ]
  end

  def root_category
    @root_category ||=
      if sc_category.parent.present?
        sc_category.parent
      else
        sc_category
      end
  end

  def full_title
    if sc_category.parent.present?
      sc_category.name + ": " + title
    else
      title
    end
  end

  TYPE_LINK = 1
  TYPE_MARKDOWN = 2
  TYPE_DOCUMENT = 3

  TYPE_HASH = {
    TYPE_LINK => "Link",
    TYPE_MARKDOWN => "Markdown",
    TYPE_DOCUMENT => "Document",
  }

  def evidential?
    sc_category.evidential?
  end

  def resolved_url
    markdown? ? "/content_items/#{self.id}" : (link? ? url : document.url)
  end

  def tool?
    tool
  end

  def type_label
    if type_mask == TYPE_MARKDOWN
      "Markdown Item"
    else
      type
    end
  end

  FORMAT_TYPE_HTML = 2
  FORMAT_TYPE_IMAGE = 3
  FORMAT_TYPE_PDF = 4
  FORMAT_TYPE_WORD_DOC = 5
  FORMAT_TYPE_VIDEO = 6

  FILTER_FORMAT_HASH = {
    FORMAT_TYPE_HTML => "Website",
    FORMAT_TYPE_PDF => "PDF",
    FORMAT_TYPE_IMAGE => "Image",
    FORMAT_TYPE_WORD_DOC => "Word Document",
    FORMAT_TYPE_VIDEO => "Video"
  }

  def self.filter_format_hash_as_form_array
    FILTER_FORMAT_HASH.to_a.map {|k,v| [k.to_s, v.to_s]}
  end

  FORMAT_HASH = {
    "pdf" => FORMAT_TYPE_PDF,
    "html" => FORMAT_TYPE_HTML,
    "htm" => FORMAT_TYPE_HTML,
    "xml" => FORMAT_TYPE_HTML,
    "php" => FORMAT_TYPE_HTML,
    "asp" => FORMAT_TYPE_HTML,
    "doc" => FORMAT_TYPE_WORD_DOC,
    "png" => FORMAT_TYPE_IMAGE,
    "tiff" => FORMAT_TYPE_IMAGE,
    "gif" => FORMAT_TYPE_IMAGE,
    "jpg" => FORMAT_TYPE_IMAGE,
    "jpeg" => FORMAT_TYPE_IMAGE,
    "svg" => FORMAT_TYPE_IMAGE,
    "www.youtube.com" => FORMAT_TYPE_VIDEO
  }

  def format_type
    if link? || document?
      theurl = link? ? url : document.url
      theurl =
        theurl.slice(theurl.rindex('.')+1..-1).downcase unless theurl.blank?
      theurl = theurl.slice(0...theurl.rindex('?')) if theurl.rindex('?')
      theurl = theurl.slice(0...theurl.rindex('#')) if theurl.rindex('#')
      ftype = FORMAT_HASH[theurl]
      ftype = FORMAT_HASH[domain] if ftype.blank?
      ftype = FORMAT_TYPE_HTML if ftype.blank? #external
      ftype
    else
      FORMAT_TYPE_HTML #internal
    end
  end

  def domain
    if link?
      SystemNotifier.catch_error(URI::InvalidURIError){ URI.parse(url).host }
    else
      return "Pathways"
    end
  end

  def format
    case format_type
      when FORMAT_TYPE_HTML
        "Website"
      when FORMAT_TYPE_IMAGE
        "Image"
      when FORMAT_TYPE_PDF
        "PDF"
      when FORMAT_TYPE_WORD_DOC
        "Word"
      when FORMAT_TYPE_VIDEO
        "Video"
      else
        ""
      end
  end

  def type
    ScItem::TYPE_HASH[type_mask]
  end

  def link?
    type_mask == ScItem::TYPE_LINK
  end

  def markdown?
    type_mask == ScItem::TYPE_MARKDOWN
  end

  def document?
    type_mask == ScItem::TYPE_DOCUMENT
  end

  def searchable?
    searchable
  end

  def shared_care?
    shared_care
  end

  def new?
    created_at > 3.week.ago.utc
  end

  def inline_content?
    markdown?
  end

  def in_category?(category_name)
    sc_category.name == category_name
  end

  alias_attribute :label, :title
  alias_attribute :name, :title
end
