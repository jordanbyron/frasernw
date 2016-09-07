task deploy_demo: [
  'deploy_demo:push',
  'deploy_demo:restart',
  'deploy_test:check_pending_migrations'
]

namespace :deploy_demo do
  task update_database: [
    :reset_database,
    :import_production_database,
    :restart,
    :check_pending_migrations
  ]
  task migrations: [
    :push,
    :off,
    :migrate,
    :restart,
    :on,
    :check_pending_migrations
  ]

  task :push do
    puts 'Finding current git branch ...'
    current_branch =
      `git branch`.
        split("\n").
        select{|b| b[0..1] == '* '}.
        first.
        sub(/[*]/, '').
        strip
    puts "Deploying site to Heroku using git branch #{current_branch} ..."

    puts `#{"git push https://git.heroku.com/pathwaysbcdemo.git "\
      "#{current_branch}:master"}`
  end

  task :restart do
    puts 'Restarting pathwaysbcdemo app servers ...'
    puts `heroku restart -a pathwaysbcdemo`
  end

  task :reset_database do
    puts 'Resetting pathwaysbcdemo database'
    puts `#{"heroku pg:reset DATABASE --app pathwaysbcdemo "\
      "--confirm pathwaysbcdemo"}`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku run rake db:migrate -a pathwaysbcdemo`
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
    puts `#{"heroku pg:reset DATABASE --app pathwaysbcdemo "\
      "--confirm pathwaysbcdemo"}`
    puts `heroku pg:push pathways_development DATABASE --app pathwaysbcdemo`
  end

  task check_pending_migrations: :environment do
    puts "Checking for pending migrations ..."
    puts `heroku run rake check_migrations --app pathwaysbcdemo`
  end
end
