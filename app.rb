require 'sinatra'
require 'koala'
require 'haml'

Dir['./config/**.rb'].each { |f| require f }
Dir['./lib/**.rb'].each { |f| require f }

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']

get '/' do
  session['access_token'] ? haml(:index) : haml(:login)
end

get '/login' do
  session['oauth'] = Koala::Facebook::OAuth.new(
    ENV['APP_ID'], ENV['APP_SECRET'], "#{request.base_url}/callback"
  )
  redirect session['oauth'].url_for_oauth_code
end

get '/logout' do
  session['oauth'] = nil
  session['access_token'] = nil
  session['user_name'] = nil
  session['user_id'] = nil

  redirect '/'
end

get '/callback' do
  access_token = session['oauth'].get_access_token(params[:code])
  user_data = Koala::Facebook::API.new(access_token).get_object("me")
  session['access_token'] = access_token
  session['user_name'] = user_data["name"]
  session['user_id'] = user_data["id"]
  ImageGenerationWorker.perform_async(user_data["id"], access_token)
  redirect '/'
end

get '/rebuild' do
  ImageGenerationWorker.perform_async(session['user_id'], session['access_token'])
  redirect '/'
end
