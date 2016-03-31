namespace :pathways do
  namespace :broken_links do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers
    require 'quick_spreadsheet'

    desc "Checks Pathways for broken links and creates a spreadsheet of them"
    task :check => :environment do
      redirected_links = []
      other_response_links = []
      error_links = []
      puts "Beginning check"
      ScItem.all.reject{ |sc| !sc.link? }.each do |sc|
        begin
          response = Net::HTTP.get_response(URI(sc.url))
          case response
          when Net::HTTPSuccess then
            puts "Link passed"
            next
          when Net::HTTPRedirection then
            redirected_links.push([sc.title, sc.url, response['location']])
            puts "Content item #{sc.title.slice(0,20).to_s.red} at #{sc.url.slice(0,30).to_s.red} redirected to #{response['location'].slice(0,30).to_s.red}"
          else
            other_response_links.push([sc.title, sc.url, response.code])
            puts "Content item #{sc.title.slice(0,20).to_s.red} at #{sc.url.slice(0,30).to_s.red} returned #{response.code.to_s.red}."
          end
        rescue Exception => e
          error_links.push([sc.title, sc.url, e.message])
          puts "Error for #{sc.title.slice(0,20).to_s.red} at #{sc.url.slice(0,30).to_s.red}: #{e.message}"
        end
      end
      puts "Finished checking"
      QuickSpreadsheet.call(
        filename: "pathways_broken_links_g#{Time.now.strftime("%Y-%m-%d-%H.%M")}",
        sheets: [
          {
            title: "Redirections",
            header_row: ["Title","URL","Redirected to"],
            body_rows: redirected_links
          },
          {
            title: "Failed responses",
            header_row: ["Title","URL","HTTP Response Code"],
            body_rows: other_response_links
          },
          {
            title: "Request errors (no response)",
            header_row: ["Title","URL","Error message"],
            body_rows: error_links
          }
        ]
      )
    end

    desc "Checks a Pathways Division for broken links"
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

    # colorization
    class String
      def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
      end

      def red
        colorize(31)
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