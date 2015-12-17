namespace :pathways do
  task :migrate_s3_buckets => :environment do
    {
      "ContentItemDocuments" => Pathways::S3.bucket_name(:content_item_documents),
      "pw-newsletters" => Pathways::S3.bucket_name(:newsletters),
      "ReferralForms" => Pathways::S3.bucket_name(:referral_forms),
      "SpecialistPhotos" => Pathways::S3.bucket_name(:specialist_photos)
    }.each do |old_bucket, new_bucket|
      puts "Migrating #{old_bucket} to #{new_bucket}"

      Pathways::S3::CloneBucket.call(
        source_bucket_name: old_bucket,
        destination_bucket_name: new_bucket
      )
    end
  end
end
