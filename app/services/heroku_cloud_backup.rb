module HerokuCloudBackup
  class << self
    def execute
      backup = client.
        transfers.
        reject{|transfer| transfer[:to_type] == "pg_restore" }.
        first

      directory = connection.directories.get(bucket_name)

      if !directory
        directory = connection.directories.create(key: bucket_name)
      end

      public_url = client.transfers_public_url(backup[:uuid])[:url]
      backup_created_at = DateTime.parse backup[:created_at]
      backup_filename = "#{backup_created_at.strftime('%Y-%m-%d-%H%M%S')}.dump"
      log "creating #{backup_path}/#{db_name}/#{name}"
      directory.
        files.
        create(
          key: "#{backup_path}/#{db_name}/#{name}",
          body: open(public_url)
        )
    end

    def client
      @client ||= HerokuCloudBackup::PGApp.new(ENV["APP_NAME"])
    end

    private

    def s3_bucket
      @s3_bucket ||= Pathways::S3.usage_reports_bucket
    end

    def log(message)
      puts "[#{Time.now}] #{message}"
    end
  end
end
