if ENV['RACK_ATTACK'].to_b
  class Rack::Attack
    safelist('allow all cloudflare IPs') do |req|
      # Requests are allowed if the return value is truthy
      # They don't hit the throttles or filters at all
      [
        "199.27.128.0",
        "173.245.48.0",
        "103.21.244.0",
        "103.22.200.0",
        "103.31.4.0",
        "141.101.64.0",
        "108.162.192.0",
        "190.93.240.0",
        "188.114.96.0",
        "197.234.240.0",
        "198.41.128.0",
        "162.158.0.0",
        "104.16.0.0",
        "172.64.0.0"
      ].include?(req.ip)
    end

    safelist("localhost") do |req|
      req.ip == '127.0.0.1'
    end

    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blocklisting and
    # safelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    ALLOWED_ASSET_PATHS = ["/app/assets", "/public"]
    throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
      if ALLOWED_ASSET_PATHS.any?{|allowed_path| req.path.starts_with?(allowed_path) }
        false
      else
        req.ip
      end
    end

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.

    # Throttle POST requests to /login by IP address
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
    throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
      if req.path == '/login' && req.post?
        req.ip
      end
    end

    # Throttle POST requests to /login by email param
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
    #
    # Note: This creates a problem where a malicious user could intentionally
    # throttle logins for another user and force their login requests to be
    # denied, but that's not very common and shouldn't happen to you. (Knock
    # on wood!)
    # throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
    #   if req.path == '/login' && req.post?
    #     # return the email if present, nil otherwise
    #     req.params['email'].presence
    #   end
    # end

    # Lockout IP addresses that are hammering your login page.
    # After 20 requests in 1 minute, block all requests from that IP for 1 hour.
    blocklist('allow2ban login scrapers') do |req|
      # `filter` returns false value if request is to your login page (but still
      # increments the count) so request below the limit are not blocked until
      # they hit the limit.  At that point, filter will return true and block.
      Rack::Attack::Allow2Ban.filter(req.ip, :maxretry => 10, :findtime => 5.minute, :bantime => 1.hour) do
        # The count for the IP is incremented if the return value is truthy.
        req.path == '/login'
      end
    end

    ### Custom Throttle Response ###

    # By default, Rack::Attack returns an HTTP 429 for throttled responses,
    # which is just fine.
    #
    # If you want to return 503 so that the attacker might be fooled into
    # believing that they've successfully broken your app (or you just want to
    # customize the response), then uncomment these lines.
    # self.throttled_response = lambda do |env|
    #  [ 503,  # status
    #    {},   # headers
    #    ['']] # body
    # end
  end
end
