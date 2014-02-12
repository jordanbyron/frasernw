class NewsItem < ActiveRecord::Base
  
  attr_accessible :division_id, :title, :body, :breaking, :start_date, :end_date, :show_start_date, :show_end_date, :type_mask
  
  belongs_to :division
    
  def date
    if start_date_full.present? && end_date_full.present? && (start_date.to_s != end_date.to_s)
      "#{start_date_full} - #{end_date_full}"
    elsif start_date_full.present?
      start_date_full
    elsif end_date_full.present?
      end_date_full
    end
  end
  
  def start_date_full
    if show_start_date?
      start_date_full_regardless
    else
      ""
    end
  end
  
  def start_date_full_regardless
    if start_date.present?
      "#{start_date.strftime('%A %B')} #{start_date.day.ordinalize}"
    else
      ""
    end
  end
  
  def end_date_full
    if show_end_date?
      end_date_full_regardless
    else
      ""
    end
  end
  
  def end_date_full_regardless
    if end_date.present?
      "#{end_date.strftime('%A %B')} #{end_date.day.ordinalize}"
    else
      ""
    end
  end
  
  TYPE_BREAKING                 = 1
  TYPE_DIVISIONAL               = 2
  TYPE_SHARED_CARE              = 3
  TYPE_SPECIALIST_CLINIC_UPDATE = 4
  TYPE_ATTACHMENT_UPDATE        = 5
  
  TYPE_HASH = {
    TYPE_DIVISIONAL               => "Divisional Update",
    TYPE_SHARED_CARE              => "Shared Care Update",
    TYPE_BREAKING                 => "Breaking News",
    TYPE_SPECIALIST_CLINIC_UPDATE => "Specialist / Clinic Update",
    TYPE_ATTACHMENT_UPDATE        => "Attachment Update"
  }
  
  def type
    TYPE_HASH[type_mask]
  end
  
  default_scope order('news_items.start_date DESC')
  
  def self.in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.division_id IN (?)", division_ids)
  end
  
  def self.breaking_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.type_mask = (?) AND (" +
    "(news_items.start_date IS NOT NULL AND news_items.end_date IS NOT NULL AND news_items.start_date <= (?) AND news_items.end_date >= (?)) OR " +
    "(news_items.start_date IS NULL AND news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR " +
    "(news_items.end_date IS NULL AND news_items.start_date IS NOT NULL AND news_items.start_date >= (?))) AND news_items.division_id IN (?)", TYPE_BREAKING, Date.today, Date.today, Date.today, Date.today, division_ids)
  end
  
  def self.divisional_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.type_mask = (?) AND (" +
    "(news_items.start_date IS NOT NULL AND news_items.end_date IS NOT NULL AND news_items.start_date <= (?) AND news_items.end_date >= (?)) OR " +
    "(news_items.start_date IS NULL AND news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR " +
    "(news_items.end_date IS NULL AND news_items.start_date IS NOT NULL AND news_items.start_date >= (?))) AND news_items.division_id IN (?)", TYPE_DIVISIONAL, Date.today, Date.today, Date.today, Date.today, division_ids)
  end
  
  def self.shared_care_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.type_mask = (?) AND (" +
    "(news_items.start_date IS NOT NULL AND news_items.end_date IS NOT NULL AND news_items.start_date <= (?) AND news_items.end_date >= (?)) OR " +
    "(news_items.start_date IS NULL AND news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR " +
    "(news_items.end_date IS NULL AND news_items.start_date IS NOT NULL AND news_items.start_date >= (?))) AND news_items.division_id IN (?)", TYPE_SHARED_CARE, Date.today, Date.today, Date.today, Date.today, division_ids)
  end
  
  def self.specialist_clinic_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.type_mask = (?) AND (" +
    "(news_items.start_date IS NOT NULL AND news_items.end_date IS NOT NULL AND news_items.start_date <= (?) AND news_items.end_date >= (?)) OR " +
    "(news_items.start_date IS NULL AND news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR " +
    "(news_items.end_date IS NULL AND news_items.start_date IS NOT NULL AND news_items.start_date >= (?))) AND news_items.division_id IN (?)", TYPE_SPECIALIST_CLINIC_UPDATE, Date.today, Date.today, Date.today, Date.today, division_ids)
  end
  
  def self.attachment_in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("news_items.type_mask = (?) AND (" +
    "(news_items.start_date IS NOT NULL AND news_items.end_date IS NOT NULL AND news_items.start_date <= (?) AND news_items.end_date >= (?)) OR " +
    "(news_items.start_date IS NULL AND news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR " +
    "(news_items.end_date IS NULL AND news_items.start_date IS NOT NULL AND news_items.start_date >= (?))) AND news_items.division_id IN (?)", TYPE_ATTACHMENT_UPDATE, Date.today, Date.today, Date.today, Date.today, division_ids)
  end
end
