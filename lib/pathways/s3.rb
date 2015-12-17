module Pathways
  module S3
    def self.repo
      AWS::S3.new(
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      )
    end

    def self.bucket_name(collection, app_name = ENV['APP_NAME'])
      "#{app_name}-#{collection.to_s.dasherize}"
    end

    def self.usage_reports_bucket
      bucket_name(:usage_reports)
    end

    class CloneBucket < ServiceObject
      attribute :source_bucket_name, String
      attribute :destination_bucket_name, String

      def call
        ensure_destination_exists!

        s3.buckets[source_bucket_name].objects.each do |object|
          next if object.key.start_with?("log/", "stats/")

          puts "Copying #{object.key}"

          object.copy_to(
            object.key,
            bucket_name: destination_bucket_name,
            acl: :public_read
          )
        end
      end

      def ensure_destination_exists!
        s3.buckets.create(destination_bucket_name) unless s3.buckets[destination_bucket_name].exists?
      end

      def s3
        @s3 ||= Pathways::S3.repo
      end
    end
  end
end
