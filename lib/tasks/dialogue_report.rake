namespace :pathways do
  task :dialogue_report => :environment do
    DialogueReport.exec
  end
end
