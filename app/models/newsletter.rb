class Newsletter < ActiveRecord::Base
  has_attached_file :document,
    storage: :s3,
    s3_protocol: :https,
    bucket: Pathways::S3.switchable_bucket_name(:newsletters),
    s3_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  validates_attachment_content_type :document,
    content_type: [
      /\Aimage\/.*\Z/,
      "application/pdf"
    ]

  has_many :description_items, class_name: "NewsletterDescriptionItem"
  accepts_nested_attributes_for :description_items
  attr_accessible :month_key,
    :description_items_attributes,
    :document

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
    document.url
  end
end
