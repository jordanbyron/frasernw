worker_processes ENV['UNICORN_PROCESSES'] # amount of unicorn workers to spin up
timeout 120                               # restarts workers that hang for 60 seconds
