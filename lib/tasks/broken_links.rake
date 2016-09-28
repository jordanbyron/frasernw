namespace :pathways do
  namespace :broken_links do
    include Net
    desc "Checks Pathways for broken links and creates a spreadsheet of them"
    task check: :environment do
      redirected_links = []
      other_response_links = []
      error_links = []
      puts "Beginning check"

      ScItem.all.reject{ |sc| !sc.link? }.each do |sc|
        begin
          uri = URI.parse(sc.url)
          http = Net::HTTP.new(uri.host, 80)
          request = Net::HTTP::Get.new(uri.request_uri,
            {
              'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) '\
                'AppleWebKit/536.26.17 (KHTML, like Gecko) '\
                'Version/6.0.2 Safari/536.26.17'
            }
          )
          response = http.request(request)
          sc_id_link =
            Spreadsheet::Link.new "pathwaysbc.ca/content_items/#{sc.id}",
              sc.id.to_s
          sc_url_link = Spreadsheet::Link.new sc.url, sc.url

          case response
          when Net::HTTPSuccess then
            puts "Link passed"
            next
          when Net::HTTPRedirection then
            if Net::HTTP.get_response(URI(sc.url)).code == "200"
              puts "Link passed"
            else
              redirection_link =
                Spreadsheet::Link.new response['location'], response['location']
              redirected_links.
                push([sc_id_link, sc.title, sc_url_link, redirection_link])
              puts "Content item #{sc.id.to_s.red}: "\
                "#{sc.title.slice(0,20).to_s.red} at "\
                "#{sc.url.slice(0,30).to_s.red} redirected to "\
                "#{response['location'].slice(0,30).to_s.red}."
            end
          else
            if Net::HTTP.get_response(URI(sc.url)).code == "200"
              puts "Link passed"
            else
              other_response_links.
                push([sc_id_link, sc.title, sc_url_link, response.code])
              puts "Content item #{sc.id.to_s.red}: "\
                "#{sc.title.slice(0,20).to_s.red} at "\
                "#{sc.url.slice(0,30).to_s.red} returned "\
                "#{response.code.to_s.red}."
            end
          end

        rescue Exception => e
          error_links.push([sc.id, sc.title, sc.url, e.message])
          puts "Error for #{sc.id.to_s.red}: #{sc.title.slice(0,20).to_s.red} "\
            "at #{sc.url.slice(0,30).to_s.red}: #{e.message}."
        end
      end

      puts "Finished checking"
      QuickSpreadsheet.call(
        file_title: "pathways_broken_links",
        sheets: [
          {
            title: "Redirections",
            header_row: [
              "ID",
              "Title",
              "URL",
              "Redirected to",
              "Replace with",
              "Notes"
            ],
            body_rows: redirected_links
          },
          {
            title: "Failed responses",
            header_row: [
              "ID",
              "Title",
              "URL",
              "HTTP Response Code",
              "Replace with",
              "Notes"
            ],
            body_rows: other_response_links
          },
          {
            title: "Request errors (no response)",
            header_row: [
              "ID",
              "Title",
              "URL",
              "Error message",
              "Replace with",
              "Notes"
            ],
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
            puts "Content item #{sc.title} at #{sc.url} redirected to "\
              "#{response['location']}."
          else
            puts "Content item #{sc.title} at #{sc.url} is not available."
          end
        rescue Exception => e
          puts "Error for #{sc.title} at #{sc.url}: #{e.message}."
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
  end
end
