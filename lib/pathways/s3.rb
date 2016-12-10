module Pathways
  module S3
    # which buckets do we want to sync and backup?
    PERSISTENT_BUCKETS = [
      :content_item_documents,
      :newsletters,
      :referral_forms,
      :specialist_photos,
      :videos
    ]

    def self.repo
      AWS::S3.new(
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      )
    end

    def self.bucket(collection)
      if PERSISTENT_BUCKETS.include?(collection)
        repo.buckets[switchable_bucket_name(collection)]
      else
        repo.buckets[bucket_name(collection)]
      end
    end

    def self.switchable_bucket_name(collection)
      if ENV["USE_BACKUP_S3_BUCKETS"] == "true"
        self.backup_bucket_name(collection)
      else
        self.bucket_name(collection)
      end
    end

    def self.backup_bucket_name(collection, app_name = ENV['APP_NAME'])
      "#{app_name}-backup-#{collection.to_s.dasherize}"
    end

    def self.bucket_name(collection, app_name = ENV['APP_NAME'])
      "#{app_name}-#{collection.to_s.dasherize}"
    end

    def self.usage_reports_bucket
      repo.buckets[bucket_name(:usage_reports)]
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
        if !s3.buckets[destination_bucket_name].exists?
          s3.buckets.create(destination_bucket_name)
        end
      end

      def s3
        @s3 ||= Pathways::S3.repo
      end
    end
  end
end
