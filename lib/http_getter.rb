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
    SCHEMES.map do |scheme|
      begin
        request_for_scheme(scheme)
      rescue Exception => exc
        next
      end
    end
  end

  def request_for_scheme(scheme)
    puts "GET #{uri(scheme)}"
    Net::HTTP.get(uri(scheme))
  end

  def uri(scheme)
    URI("#{scheme}://#{ENV['DOMAIN']}/#{path}")
  end
end
