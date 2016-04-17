namespace :pathways do
  task :mirror_s3 => :environment do
    destination_app_name = ENV['APP_NAME']

    if destination_app_name == "pathwaysbc"
      raise "Can't mirror production against itself!"
    end

    Pathways::S3::PERSISTENT_BUCKETS.each do |collection|
      puts "Mirroring #{collection}"

      Pathways::S3::CloneBucket.call(
        source_bucket_name: Pathways::S3.bucket_name(collection, "pathwaysbc"),
        destination_bucket_name: Pathways::S3.bucket_name(collection, destination_app_name)
      )
    end
  end
end
