Rack::Timeout.timeout = Integer(ENV["RACK_SERVICE_TIMEOUT"] || 15)  # seconds  ##Default: 15
# records time from when a unicorn process starts working on a request, does not include time waiting in request queue

Rack::Timeout.wait_timeout = Integer(ENV["RACK_WAIT_TIMEOUT"] || 30) #seconds  ##Default: 30
# records total time from the START of a request, includes time waiting in request queue.