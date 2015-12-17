namespace :pathways do
  task :mirror_s3 => :environment do
    [
      :content_item_documents,
      :newsletters,
      :referral_forms,
      :specialist_photos,
    ].each do |collection|
      puts "Migrating #{old_bucket} to #{new_bucket}"

      Pathways::S3::CloneBucket.call(
        source_bucket_name: Pathways::S3.bucket_name(collection, "pathwaysbc"),
        destination_bucket_name: Pathways::S3.bucket_name(collection)
      )
    end
  end
end
