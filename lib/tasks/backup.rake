namespace :pathways do
  task :backup => :environment do
    require "heroku_cloud_backup"

    puts "Cloning database backup to S3..."
    HerokuCloudBackup.execute

    puts "Backing up S3 buckets to a different region..."
    Pathways::S3::PERSISTENT_BUCKETS.each do |collection|
      puts "Backing up #{collection}"

      Pathways::S3::CloneBucket.call(
        source_bucket_name: Pathways::S3.bucket_name(collection),
        destination_bucket_name: Pathways::S3.backup_bucket_name(collection)
      )
    end

    puts "Backup complete."
  end
end
