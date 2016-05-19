class Video < ActiveRecord::Base
  attr_accessible :title, :video_clip

  has_attached_file :video_clip,
    storage: :s3,
    s3_protocol: :https,
    bucket: Pathways::S3.switchable_bucket_name(:videos),
    s3_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  validates_attachment_presence :video_clip
  do_not_validate_attachment_file_type :video_clip

  def self.current
    ordered.first
  end

  def self.ordered
    order("created_at DESC")
  end

end
