web: bundle exec rackup config.ru -p $PORT
sidekiq: bundle exec sidekiq -c 5 -r ./lib/image_generation_worker.rb