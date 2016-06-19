task :prepare_create_seeds do
  `script/import_prod_db`
  `rake db:migrate`
end

task :create_seeds => [:prepare_create_seeds, :environment] do
  CreateSeeds.call
end
