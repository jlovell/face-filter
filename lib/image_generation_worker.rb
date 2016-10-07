require 'sidekiq'
require 'koala'
require './lib/filter_image'
require './lib/photo'

class ImageGenerationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(user_id, access_token)
    graph = Koala::Facebook::API.new(access_token)
    image_data = graph.get_object("me/picture", {
      redirect: false, type: 'square', width: 960, height: 960
    })
    image_url = image_data.dig("data", "url")
    return unless image_url

    image_blob = open(image_url).read
    Photo.for_id(user_id).store(:original, image_blob)

    overlayed = FilterImage.from_blob(image_blob)
    Photo.for_id(user_id).store(:overlay, overlayed.to_blob)

    %w(L B G T Q A).each do |letter|
      lettered = FilterImage.from_blob(image_blob, letter: letter)
      Photo.for_id(user_id).store(letter, lettered.to_blob)
    end
  end
end
