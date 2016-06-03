task :deploy_demo => ['deploy_demo:push', 'deploy_demo:restart']

namespace :deploy_demo do
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
    puts `heroku restart -a pathwaysbcdemo`
  end

  task :reset_database do
    puts 'Resetting pathwaysbcDEV database'
    puts `heroku pg:reset DATABASE --app pathwaysbcdemo --confirm pathwaysbcdemo`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku rake db:migrate -a pathwaysbcdemo`
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on -a pathwaysbcdemo`
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off -a pathwaysbcdemo`
  end

  task :push_local_db do
    puts `heroku pg:reset DATABASE --app pathwaysbcdemo --confirm pathwaysbcdemo`
    puts `heroku pg:push pathways_development DATABASE --app pathwaysbcdemo`
  end
end
