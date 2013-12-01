task :backup_db => :environment do
  require "heroku_cloud_backup"
  puts "Backing up database..."
  HerokuCloudBackup.execute
  puts "done."
end