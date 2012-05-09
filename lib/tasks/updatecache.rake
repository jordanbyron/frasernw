task :update_cache => :environment do
  RakeUpdateCacheSweeper.rake_update_cache_extern
  puts "done."
end