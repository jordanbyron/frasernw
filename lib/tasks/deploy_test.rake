require 'open3'
task :deploy_test => ['deploy_test:push', 'deploy_test:restart']

namespace :deploy_test do
  task :migrations => [:push, :off, :migrate, :restart, :on]
  task :rollback => [:off, :push_previous, :restart, :on]
  task :update_database => [:reset_database, :import_production_database]

  task :push do
    puts 'Finding current git branch ...'
    current_branch = `git branch`.split("\n").select{|b| b[0..1] == '* '}.first.sub(/[*]/, '').strip
    puts "Deploying site to Heroku using git branch #{current_branch} ..."

    puts `git push heroku_pathways_test #{current_branch}:master`
  end

  task :restart do
    puts 'Restarting app servers ...'
    puts `heroku restart -a pathwaysbctest`
  end

  # task :tag do

  #   # time_zone_offset = 3600 * -8  # Use Pacific Time

  #   # # find the zone with that offset
  #   # zone_name = ActiveSupport::TimeZone::MAPPING.keys.find do |name|
  #   #   ActiveSupport::TimeZone[name].utc_offset == time_zone_offset
  #   # end

  #   # # get time in the right time zone for the git tag
  #   # zone = ActiveSupport::TimeZone[zone_name]
  #   # time_zone = Time.zone
  #   # time_zone = zone

  #   # name git tag with time
  #   # release_name = "#{time_zone.now.strftime("%Y_%m_%d_deploy_%H:%M:%S")}"
  #   release_name = "release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"

  #   puts "Tagging release to git as: #{release_name}"
  #   puts `git tag -a #{release_name} -m 'Tagged release'`

  #   puts `git push origin #{release_name}`
  #   # puts `git push --tags heroku`
  # end

  task :reset_database do
    puts 'Resetting pathwaysbcTEST database'
    puts `heroku pg:reset DATABASE --app pathwaysbctest --confirm pathwaysbctest`
  end

  task :import_production_database do
    puts 'Copying production database to pathwaysbcTEST database'
    puts `heroku pg:reset DATABASE --app pathwaysbctest --confirm pathwaysbctest`
    # system %x{heroku pg:backups restore HEROKU_POSTGRESQL_BLUE_URL -a pathwaysbctest `heroku pg:backups public-url -a pathwaysbc`}
    # `heroku run 'cd vendor/my_engine && rake db:migrate' -a my-app`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku rake db:migrate -a pathwaysbctest`
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on -a pathwaysbctest`
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off -a pathwaysbctest`
  end
end
