namespace :pathways do
  namespace :dialogue_report do
    namespace :user_types do
      task :users, [:start_month, :end_month, :folder_path] => :environment do |t, args|
        DialogueReport::UserTypeUsers.new(args).exec
      end
    end
  end
end
