namespace :pathways do
  task :populate_metrics => :environment do
    Analytics::Populator::All.exec
  end
end
