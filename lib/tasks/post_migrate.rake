namespace :pathways do
  task :post_migrate do
    at_exit { VerifySeedCreators::Warn.call }
  end
end

Rake::Task['db:migrate'].enhance(['pathways:post_migrate'])
