 module S3
  def self.usage_report_bucket
    repo.buckets[ENV['S3_BUCKET_NAME']]
  end

  def self.repo
    AWS::S3.new(
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )
  end
end
