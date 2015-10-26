class Newsletter < ActiveRecord::Base
  has_attached_file :newsletter,
  :storage => :s3,
  :s3_protocol => :https,
  :bucket => ENV['S3_BUCKET_NAME_NEWSLETTERS'],
  :s3_credentials => {
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  }

  has_many :description_items, class_name: "NewsletterDescriptionItem"
  accepts_nested_attributes_for :description_items
  attr_accessible :month_key,
    :description_items_attributes,
    :newsletter

  def self.current
    ordered.first
  end

  def self.ordered
    order("month_key DESC")
  end

  def month
    Month.from_i(month_key).full_name
  end

  def url
    newsletter.url
  end
end
