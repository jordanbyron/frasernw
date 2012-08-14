class ScItem < ActiveRecord::Base
  attr_accessible :sc_category_id, :specialization_ids, :tool, :type_mask, :title, :searchable, :shared_care, :inline, :url, :markdown_content
  
  belongs_to  :sc_category
  
  has_many    :sc_item_specializations, :dependent => :destroy
  has_many    :specializations, :through => :sc_item_specializations

  has_many    :sc_item_specialization_procedure_specializations, :through => :sc_item_specializations
  has_many    :procedure_specializations, :through => :sc_item_specialization_procedure_specializations
 
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  
  def self.for_specialization(specialization)
    joins(:sc_item_specializations).where("sc_item_specializations.specialization_id = ?", specialization.id)
  end
  
  def self.for_procedure_specialization(procedure_specialization)
joins([:sc_item_specializations, :sc_item_specialization_procedure_specializations]).where("sc_item_specializations.id = sc_item_specialization_procedure_specializations.sc_item_specialization_id AND sc_item_specialization_procedure_specializations.procedure_specialization_id = ?", procedure_specialization.id)
  end
  
  def self.searchable
    where("sc_items.searchable = ?", true)
  end
  
  def self.tool
    where("sc_items.tool = ?", true)
  end
  
  TYPE_HASH = {
    1 => "Link", 
    2 => "Markdown", 
  }

  def tool?
    tool
  end
  
  def type
    ScItem::TYPE_HASH[type_mask]
  end

  def link?
    type_mask == 1
  end

  FORMAT_TYPE_INTERNAL = 0
  FORMAT_TYPE_EXTERNAL = 1
  FORMAT_TYPE_HTML = 2
  FORMAT_TYPE_IMAGE = 3
  FORMAT_TYPE_PDF = 4
  FORMAT_TYPE_WORD_DOC = 5
  FORMAT_TYPE_VIDEO = 6

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
    if link?
      ftype = FORMAT_HASH[url.slice(url.rindex('.')+1..-1).downcase]
      ftype = FORMAT_HASH[domain] if ftype.blank?
      ftype = FORMAT_TYPE_EXTERNAL if ftype.blank?
      ftype
    else
      FORMAT_TYPE_INTERNAL
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
        "web page"
      when FORMAT_TYPE_EXTERNAL
        "web page"
      when FORMAT_TYPE_HTML
        "web page"
      when FORMAT_TYPE_IMAGE
        "image"
      when FORMAT_TYPE_PDF
        "pdf"
      when FORMAT_TYPE_WORD_DOC
        "word document"
      when FORMAT_TYPE_VIDEO
        "video"
      else
        ""
      end
  end
      
  def markdown?
    type_mask == 2
  end

  def inline?
    inline
  end

  def searchable?
    searchable
  end

  def shared_care?
    shared_care
  end
end
