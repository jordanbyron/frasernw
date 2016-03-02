task :clone_backup_to_s3 => :environment do
  require "heroku_cloud_backup"
  puts "Backing up database..."
  HerokuCloudBackup.execute
  puts "done."
end
