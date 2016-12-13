def print_exec(cmd)
  puts cmd
  puts `#{cmd}`
end

namespace :deploy do
  [
    [ "production", "pathwaysbc", "master" ],
    [ "test", "pathwaysbctest", "deploy-test" ],
    [ "demo", "pathwaysbcdemo", "master" ]
  ].each do |config|
    namespace config[0] do
      task :push do
        puts "Deploying site to #{config[0].capitalize}"

        flags = config[0] == "test" ? "-f" : ""

        print_exec "git push #{flags} https://git.heroku.com/#{config[1]}.git "\
          "#{config[2]}:master"

        puts "Checking for pending migrations ..."
        print_exec "heroku run rake check_migrations --app #{config[1]}"
      end

      task :migrate do
        puts "Migrating and restarting #{config[0].capitalize}"

        print_exec "heroku run rake db:migrate --app #{config[1]}"
        print_exec "heroku restart --app #{config[1]}"
      end

      task :push_local_database do
        if config[0] == "production"
          puts "Comment these lines if you are certain we need to replace the "\
            "production database."
          return
        end

        puts "Are you sure you would like to replace the database at #{config[1]} with "\
          "your local database?  Confirm by typing the name of the remote."
        if STDIN.gets.chomp != config[1]
          puts "Aborting"
          return
        end

        puts "Please confirm again.  This will overwrite the database at #{config[1]}! "
        if STDIN.gets.chomp != config[1]
          puts "Aborting"
          return
        end

        print_exec "heroku pg:reset DATABASE --app #{config[1]} --confirm #{config[1]}"
        print_exec "heroku pg:push pathways_development DATABASE_URL --app #{config[1]}"
        print_exec "heroku run rake reset_pkey_sequence --app #{config[1]}"
      end
    end
  end

  namespace :test do
    task :import_production_database do
      puts 'Copying production database to test'
      print_exec "heroku pg:copy pathwaysbc::HEROKU_POSTGRESQL_GOLD_URL "\
        "pathwaysbctest::HEROKU_POSTGRESQL_WHITE_URL "\
        "--app pathwaysbctest --confirm pathwaysbctest"
    end

    task :mirror_s3 do
      puts "Copying production s3 to test"
      print_exec "APP_NAME=pathwaysbctest rake pathways:mirror_s3"
    end

    task :clean_branch do
      puts "Creating a clean 'deploy-test' branch"

      print_exec "git checkout master"

      print_exec "git push origin deploy-test --delete"
      print_exec "git branch -D deploy-test"

      print_exec "git pull"
      print_exec "git checkout -b deploy-test"
      print_exec "git push origin deploy-test:deploy-test --set-upstream"
    end
  end
end
