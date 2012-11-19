class NewsItem < ActiveRecord::Base
    
  def date
    if start_date.present? && end_date.present? && (start_date.to_s != end_date.to_s)
      "#{start_date_full} - #{end_date_full}"
    elsif start_date.present?
      start_date_full
    end
  end
  
  def start_date_full
    if start_date.present?
      "#{start_date.strftime('%A %B')} #{start_date.day.ordinalize}"
    else
      ""
    end
  end
  
  def end_date_full
    if end_date.present?
      "#{end_date.strftime('%A %B')} #{end_date.day.ordinalize}"
    else
      ""
    end
  end
    
  default_scope order('news_items.start_date')
  
  def self.breaking
    where("news_items.breaking = ? AND ((news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR (news_items.end_date IS NULL AND news_items.start_date >= (?)))", true, Date.today, Date.today)
  end
  
  def self.news
    where("news_items.breaking = ? AND ((news_items.end_date IS NOT NULL AND news_items.end_date >= (?)) OR (news_items.end_date IS NULL AND news_items.start_date >= (?)))", false, Date.today, Date.today)
  end
end
