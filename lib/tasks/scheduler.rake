require "heroku_backup_task"
require "heroku_cloud_backup"
task :backup_db => :environment do
    puts "Updating feed..."
    HerokuBackupTask.execute
    HerokuCloudBackup.execute
    puts "done."
end