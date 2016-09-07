task deploy_test: [
  'deploy_test:push',
  'deploy_test:restart',
  'deploy_test:check_pending_migrations'
]

namespace :deploy_test do
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

    puts `#{"git push https://git.heroku.com/pathwaysbctest.git "\
      "#{current_branch}:master"}`
  end

  task :restart do
    puts 'Restarting pathwaysbcTEST app servers ...'
    puts `heroku restart -a pathwaysbctest`
  end

  task :reset_database do
    puts 'Resetting pathwaysbcTEST database'
    puts `#{"heroku pg:reset DATABASE --app pathwaysbctest "\
      "--confirm pathwaysbctest"}`
  end

  task :import_production_database do
    puts 'Copying production database to pathwaysbcTEST database'
    puts `#{"heroku pg:copy pathwaysbc::DATABASE_URL WHITE -a pathwaysbctest "\
      "--confirm pathwaysbctest"}`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku run rake db:migrate -a pathwaysbctest`
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on -a pathwaysbctest`
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off -a pathwaysbctest`
  end

  task check_pending_migrations: :environment do
    puts "Checking for pending migrations ..."
    puts `heroku run rake check_migrations --app pathwaysbctest`
  end
end
