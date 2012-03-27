require "heroku_cloud_backup"
task :backup_db => :environment do
    puts "Backing up database..."
    HerokuCloudBackup.execute
    puts "done."
end