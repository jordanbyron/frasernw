class ScItem < ActiveRecord::Base
  attr_accessible :sc_category_id, :specialization_ids, :type_mask, :title, :searchable, :shared_care, :url, :markdown_content, :document, :can_email_document, :can_email_link, :shareable, :division_id
  
  belongs_to  :sc_category
  
  has_many    :sc_item_specializations, :dependent => :destroy
  has_many    :specializations, :through => :sc_item_specializations

  has_many    :sc_item_specialization_procedure_specializations, :through => :sc_item_specializations
  has_many    :procedure_specializations, :through => :sc_item_specialization_procedure_specializations
  
  has_many    :feedback_items, :as => :item, :conditions => { "archived" => false }
  has_many    :archived_feedback_items, :as => :item, :foreign_key => "item_id", :class_name => "FeedbackItem"
  
  belongs_to  :division
  
  has_many    :division_display_sc_items, :dependent => :destroy
  has_many    :divisions_sharing, :through => :division_display_sc_items, :class_name => "Division"
  
  has_attached_file :document,
  :storage => :s3,
  :bucket => ENV['S3_BUCKET_NAME_CONTENT_DOCUMENTS'],
  :s3_credentials => {
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  }
 
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  
  default_scope order('sc_items.title')
  
  def self.not_in_progress_for_divisions(divisions)
    division_ids = divisions.map{ |division| division.id }
    joins('INNER JOIN "sc_item_specializations" ON "sc_item"."id" = "sc_item_specializations"."sc_item_id" INNER JOIN "specialization_options" ON "specialization_options"."specialization_id" = "sc_item_specializations"."specialization_id"').where('"specialization_options"."division_id" IN (?) AND "specialization_options"."in_progress" = (?)', division_ids, false)
  end

  def in_progress_for_divisions(divisions)
    specialization_options = specializations.map{ |s| s.specialization_options.for_divisions(divisions) }.flatten
    (specialization_options.length > 0) && (specialization_options.reject{ |so| so.in_progress }.length == 0)
  end
  
  def self.for_specialization_in_divisions(specialization, divisions)
    division_ids = divisions.map{ |d| d.id }
    owned = joins(:sc_item_specializations).where('"sc_item_specializations"."specialization_id" = (?) AND "sc_items"."division_id" IN (?)', specialization.id, division_ids)
    shared = joins(:sc_item_specializations, :division_display_sc_items).where('"sc_item_specializations"."specialization_id" = (?) AND "division_display_sc_items"."division_id" in (?) AND "sc_items"."shareable" = (?)', specialization.id, division_ids, true)
    (owned + shared).uniq
  end
  
  def self.for_procedure_in_divisions(procedure, divisions)
    division_ids = divisions.map{ |d| d.id }
    owned = joins([:sc_item_specializations, :sc_item_specialization_procedure_specializations, :procedure_specializations]).where('sc_item_specializations.id = sc_item_specialization_procedure_specializations.sc_item_specialization_id AND sc_item_specialization_procedure_specializations.procedure_specialization_id = procedure_specializations.id AND procedure_specializations.procedure_id = (?) AND "sc_items"."division_id" IN (?)', procedure.id, division_ids)
    shared = joins([:sc_item_specializations, :sc_item_specialization_procedure_specializations, :procedure_specializations, :division_display_sc_items]).where('sc_item_specializations.id = sc_item_specialization_procedure_specializations.sc_item_specialization_id AND sc_item_specialization_procedure_specializations.procedure_specialization_id = procedure_specializations.id AND procedure_specializations.procedure_id = (?) AND "division_display_sc_items"."division_id" in (?) AND "sc_items"."shareable" = (?)', procedure.id, division_ids, true)
    (owned + shared).uniq
  end
  
  def self.owned_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where('"sc_items"."division_id" IN (?)', division_ids)
  end
  
  def self.shared_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins('INNER JOIN "division_display_sc_items" ON "division_display_sc_items"."sc_item_id" = "sc_items"."id"').where('"division_display_sc_items"."division_id" in (?) AND "sc_items"."shareable" = (?)', division_ids, true)
  end
  
  def self.shareable_by_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where('"sc_items"."division_id" in (?) AND "sc_items"."shareable" = (?)', division_ids, true)
  end
  
  def self.shareable
    where('"sc_items"."shareable" = (?)', true)
  end
  
  def self.all_in_divisions(divisions)
    (owned_in_divisions(divisions) + shared_in_divisions(divisions)).uniq
  end
  
  def self.searchable
    where("sc_items.searchable = (?)", true)
  end

  def available_to_divisions(divisions)
    (divisions.include? division) || (shareable? && (divisions & divisions_sharing).present?)
  end

  def mail_to_patient(current_user, patient_email)
    MailToPatientMailer.mail_to_patient(self, current_user, patient_email).deliver
  end

  def owner
    if specializations.blank? || division.blank?
      return default_content_owner
    end
    
    #We only have one division for each conten item, so lets find that the first owner in one of the specializations
    specializations.each do |specialization|
      specialization.specialization_options.for_divisions([division]).each do |so|
        return so.content_owner if so.content_owner.present?
      end
    end
    
    #There is no owner for the any of the specializations this content item is in...
    return default_content_owner
  end

  def root_category
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
  
  TYPE_HASH = {
    1 => "Link",
    2 => "Markdown",
    3 => "Document",
  }

  def can_email?
    ((type_mask == 1 && can_email_link?) || (type_mask == 3 && can_email_document?))
  end

  def resolved_url
    markdown? ? "/content_items/#{self.id}" : (link? ? url : document.url)
  end

  def tool?
    tool
  end

  FORMAT_TYPE_INTERNAL = 0
  FORMAT_TYPE_EXTERNAL = 1
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

  FORMAT_HASH = {
    "pdf" => FORMAT_TYPE_PDF,
    "html" => FORMAT_TYPE_HTML,
    "htm" => FORMAT_TYPE_HTML,
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
      theurl = theurl.slice(theurl.rindex('.')+1..-1).downcase              #take everything after the last period
      theurl = theurl.slice(0...theurl.rindex('?')) if theurl.rindex('?')   #take off anything after a ?
      theurl = theurl.slice(0...theurl.rindex('#')) if theurl.rindex('#')   #take off anything after a #
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
      require 'uri'
      URI.parse(url).host
    else
      return "Pathways"
    end
  end

  def format
    case format_type
      when FORMAT_TYPE_INTERNAL
        "Pathways"
      when FORMAT_TYPE_EXTERNAL
        "Website"
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
    type_mask == 1
  end
      
  def markdown?
    type_mask == 2
  end
      
  def document?
    type_mask == 3
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
end
