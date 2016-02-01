task :deploy => ['deploy:backup', 'deploy:show_backups', 'deploy:push', 'deploy:restart', 'deploy:tag']

namespace :deploy do
  task :migrations => [:backup, :show_backups, :push, :off, :migrate, :restart, :on, :tag]
  task :rollback => [:off, :push_previous, :restart, :on]

  task :backup do
    puts 'Backing up existing database'
    puts `heroku pg:backups capture --app pathwaysbc`
  end

  task :show_backups do
    puts "Showing listing previous backups ..."
    puts `heroku pg:backups --app pathwaysbc`
  end

  task :push do
    # puts 'Finding current git branch ...'
    # current_branch = `git branch`.split("\n").select{|b| b[0..1] == '* '}.first.sub(/[*]/, '').strip
    # puts "Deploying site to Heroku using git branch #{current_branch} ..."
    puts "Deploy site to Production"

    puts `git push heroku_pathways master:master`
  end

  task :restart do
    puts 'Restarting Production app servers ...'
    puts `heroku restart -a pathwaysbc`
  end

  task :tag do
    release_name = "release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"

    puts "Tagging release to git as: #{release_name}"
    puts `git tag -a #{release_name} -m 'Tagged release'`

    puts `git push origin #{release_name}`
    # puts `git push --tags heroku`
  end

  task :migrate do
    puts 'Running database migrations ...'
    puts `heroku rake db:migrate -a pathwaysbc`
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    puts `heroku maintenance:on -a pathwaysbc`
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off -a pathwaysbc`
  end

  task :push_previous do
    releases = `git tag`.split("\n").select { |t| t[0..7] == 'release-' }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "Rolling back to '#{previous_release}' ..."

      puts "Checking out '#{previous_release}' in a new branch on local git repo ..."
      puts `git checkout #{previous_release}`
      puts `git checkout -b #{previous_release}`

      puts "Removing tagged version '#{previous_release}' (now transformed in branch) ..."
      puts `git tag -d #{previous_release}`
      puts `git push heroku_pathways :refs/tags/#{previous_release}`

      puts "Pushing '#{previous_release}' to Heroku master ..."
      puts `git push heroku_pathways +#{previous_release}:master --force`

      puts "Deleting rollbacked release '#{current_release}' ..."
      puts `git tag -d #{current_release}`
      puts `git push heroku_pathways :refs/tags/#{current_release}`

      puts "Retagging release '#{previous_release}' in case to repeat this process (other rollbacks)..."
      puts `git tag -a #{previous_release} -m 'Tagged release'`
      puts `git push --tags heroku_pathways`

      puts "Turning local repo checked out on master ..."
      puts `git checkout master`
      puts 'All done!'
    else
      puts "No release tags found - can't roll back!"
      puts releases
    end
  end
end
