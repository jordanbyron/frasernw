task :deploy_dev => ['deploy_dev:push', 'deploy_dev:restart']

namespace :deploy_dev do
  task :update_database => [:reset_database, :import_production_database, :restart]
  task :migrations => [:push, :off, :migrate, :restart, :on]

  task :push do
    puts 'Finding current git branch ...'
    current_branch = `git branch`.split("\n").select{|b| b[0..1] == '* '}.first.sub(/[*]/, '').strip
    puts "Deploying site to Heroku using git branch #{current_branch} ..."

    puts `git push heroku_pathways_dev #{current_branch}:master`
  end

  task :restart do
    puts 'Restarting pathwaysbcDEV app servers ...'
    puts `heroku restart -a pathwaysbcdev`
  end

  task :reset_database do
    puts 'Resetting pathwaysbcDEV database'
    puts `heroku pg:reset DATABASE --app pathwaysbcdev --confirm pathwaysbcdev`
  end

  task :import_production_database do
    puts 'Copying production database to pathwaysbcDEV database'
    puts `heroku pg:copy pathwaysbc::DATABASE_URL PURPLE --app pathwaysbcdev --confirm pathwaysbcdev`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku rake db:migrate -a pathwaysbcdev`
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on -a pathwaysbcdev`
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off -a pathwaysbcdev`
  end
end
