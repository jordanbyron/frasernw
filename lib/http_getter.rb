class HttpGetter

  def self.exec(path)
    new(path).exec
  end

  SCHEMES = ["http", "https"]

  attr_reader :path, :scheme

  def initialize(path)
    @path = path
  end

  def exec
    SCHEMES.each do |scheme|
      begin
        request_for_scheme(scheme)
      rescue Exception => exc
        next
      end
    end
  end

  def request_for_scheme(scheme)
    Net::HTTP.get(uri(scheme))
  end

  def uri(scheme)
    puts "GET #{scheme}://#{APP_CONFIG[:domain]}/#{path}"
    URI("#{scheme}://#{APP_CONFIG[:domain]}/#{path}")
  end
end

    # class HttpGetter

    #   def self.exec(path)
    #     new(path).exec
    #   end

    #   SCHEMES = ["http", "https"]

    #   attr_reader :path

    #   def initialize(path)
    #     @path = path
    #   end

    #   def exec
    #     SCHEMES.each do |scheme|
    #       request_for_scheme(scheme)
    #     end
    #   end

    #   def request_for_scheme(scheme)
    #     Net::HTTP.get(uri)
    #   end

    #   def uri
    #     URI("#{scheme}://#{APP_CONFIG[:domain]}/#{path}")
    #   end
    # end

    # #mock out net::HTTP, set expectation for it to receive the urls you want

    # HttpGetter.exec("specialties/#{s.id}/#{s.token}/refresh_cache")


