ENV ||= {}
ENV['PORT'] = '5000'
require 'sinatra/base'
require 'koala'
require 'haml'

Dir['./config/**.rb'].each { |f| require f }
Dir['./lib/**.rb'].each { |f| require f }

class FaceFilter < Sinatra::Application
  include SessionHelper

  use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']

  get '/' do
    signed_in? ? haml(:index) : haml(:login)
  end

  get '/welcome' do
    haml :welcome
  end

  get '/login' do
    session['oauth'] = Koala::Facebook::OAuth.new(
      ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], "#{request.base_url}/callback"
    )
    redirect session['oauth'].url_for_oauth_code
  end

  get '/logout' do
    sign_out
    redirect '/'
  end

  get '/callback' do
    access_token = session['oauth'].get_access_token(params[:code])
    user_data = Koala::Facebook::API.new(access_token).get_object("me")
    sign_in(access_token, user_data)
    PhotoGeneration.store_original(user_data["id"], access_token)
    ImageGenerationWorker.perform_async(user_data["id"], access_token)
    redirect '/'
  end

  get '/rebuild' do
    ImageGenerationWorker.perform_async(session['user_id'], session['access_token'])
    redirect '/'
  end

  get '/face/:id/?:type?' do
    @requested_photo_url = Photo.for_id(params[:id]).url(params[:type])
    haml(:shared)
  end

  get '/image/:id/?:type?' do
    content_type 'image/jpg'
    Photo.for_id(params[:id]).get(params[:type])
  end

  get '/download/:id/?:type?' do
    content_type 'image/jpeg'
    send_file(Magick::Image.from_blob(Photo.for_id(params[:id]).get(params[:type])).first.to_blob,
              :disposition => 'attachment',
              :filename => 'comingout.jpg')
  end

  get '/share/:id/?:type?' do
    @graph_image = "#{request.base_url}/image/#{params[:id]}"
    @graph_image += "/#{params[:type]}" if params[:type]
    signed_in? ? redirect('/') : haml(:login)
  end

end
