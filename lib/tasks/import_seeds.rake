task :fresh_db do
  `rake db:drop`
  `rake db:create`
  `rake db:schema:load`
end

task import_seeds: [:fresh_db, :environment] do
  ImportSeeds.call
end
