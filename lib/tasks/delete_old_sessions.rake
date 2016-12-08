namespace :pathways do
  task :delete_old_sessions => :environment do
    # When a user closes their session without logging out, our database keeps a record of the session despite not getting used again.
    # This task prevents old session cruft from growing the Sessions table into tens of millions of rows.
    puts "BEGIN deletion of old session data..."

    before = ActiveRecord::SessionStore::Session.count


    puts "Total Sessions BEFORE delete: #{before}"

    ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 2.weeks.ago])

    after = ActiveRecord::SessionStore::Session.count
    puts "Total Sessions AFTER delete: #{after}"

    puts "Deletion complete! #{before - after} Old Sessions Deleted"
  end
end
