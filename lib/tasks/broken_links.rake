namespace :pathways do
  namespace :broken_links do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers
  
    task :check => :environment do
      ScItem.all.reject{ |sc| !sc.link? }.each do |sc|
        begin
          response = Net::HTTP.get_response(URI(sc.url))
          case response
          when Net::HTTPSuccess then
            next
          when Net::HTTPRedirection then
            puts "Content item #{sc.title} at #{sc.url} redirected to #{response['location']}"
          else
            puts "Content item #{sc.title} at #{sc.url} does not seem to be available"
          end
        rescue Exception => e
          puts "Error for #{sc.title} at #{sc.url}: #{e.message}"
        end
      end
    end
    
    task :check_division, [:division_id] => [:environment] do |t, args|
      d = Division.find(args[:division_id])
      ScItem.owned_in_divisions([d]).reject{ |sc| !sc.link? }.each do |sc|
        begin
          response = Net::HTTP.get_response(URI(sc.url))
          case response
          when Net::HTTPSuccess then
            next
          when Net::HTTPRedirection then
            puts "Content item #{sc.title} at #{sc.url} redirected to #{response['location']}"
          else
            puts "Content item #{sc.title} at #{sc.url} does not seem to be available"
          end
        rescue Exception => e
          puts "Error for #{sc.title} at #{sc.url}: #{e.message}"
        end
      end
    end

    # The following methods are defined to fake out the ActionController
    # requirements of the Rails cache
    
    def cache_store
      ActionController::Base.cache_store
    end
    
    def self.benchmark( *params )
      yield
    end
    
    def cache_configured?
      true
    end
  
    
  end
end