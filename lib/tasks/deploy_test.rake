task :deploy_test => ['deploy_test:push', 'deploy_test:restart']

namespace :deploy_test do
  task :update_database => [:reset_database, :import_production_database, :restart]
  task :migrations => [:push, :off, :migrate, :restart, :on]

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

  task :reset_database do
    puts 'Resetting pathwaysbcTEST database'
    puts `heroku pg:reset DATABASE --app pathwaysbctest --confirm pathwaysbctest`
  end

  task :import_production_database do
    puts 'Copying production database to pathwaysbcTEST database'
    puts `heroku pg:copy pathwaysbc::DATABASE_URL BLUE -a pathwaysbctest --confirm pathwaysbctest`
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
