web: bundle exec rackup config.ru -p $PORT
sidekiq: bundle exec sidekiq -r ./lib/image_generation_worker.rb