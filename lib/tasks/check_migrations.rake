task check_migrations: :environment do
  log_path = Rails.root + 'log/last_migrations_check.log'
  puts "Checking migrations"
  puts `rake db:migrate:status > #{log_path}`
  migration_status_output = IO.binread(log_path)
  pending_migrations = []
  migration_status_output.split("\n").each do |line|
    if line[0..10].include? "down"
      pending_migrations << line
    end
  end
  if pending_migrations.any?
    puts "There are pending migrations!"
    SystemNotifier.migrations_pending(pending_migrations.count)
  else
    puts "Migrations checked."
  end
end
