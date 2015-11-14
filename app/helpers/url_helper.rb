module UrlHelper
  def base_url
    uri  = URI.parse(request.url)
    uri.path  = ''
    uri.query = nil

    uri.to_s
  end
end
