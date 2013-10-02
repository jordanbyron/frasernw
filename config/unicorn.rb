worker_processes Integer(ENV['UNICORN_PROCESSES'] || 5) # amount of unicorn workers to spin up
timeout 120                               # restarts workers that hang for 60 seconds
