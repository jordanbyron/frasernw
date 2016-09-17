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
        print_exec "git push https://git.heroku.com/#{config[1]}.git #{config[2]}:master"
        puts "Checking for pending migrations ..."
        print_exec "heroku run rake check_migrations --app #{config[1]}"
      end
    end
  end

  namespace :test do
    task :import_production_database do
      puts 'Copying production database to test'
      print_exec "heroku pg:copy pathwaysbc::DATABASE_URL WHITE -a pathwaysbctest "\
        "--confirm pathwaysbctest"
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

  namespace :demo do
    task :push_local_database do
      print_exec "heroku pg:reset DATABASE --app pathwaysbcdemo --confirm pathwaysbcdemo"
      print_exec "heroku pg:push pathways_development DATABASE_URL --app pathwaysbcdemo"
      print_exec "heroku run rake reset_pkey_sequence --app pathwaysbcdemo"
    end
  end
end
