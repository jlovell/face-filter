class PhotoGeneration
  def self.store_original(user_id, access_token)
    graph = Koala::Facebook::API.new(access_token)
    image_data = graph.get_object("me/picture", {
      redirect: false, type: 'square', width: 960, height: 960
    })
    image_url = image_data.dig("data", "url")
    return unless image_url

    image_blob = open(image_url).read
    Photo.for_id(user_id).store(:original, image_blob)
  end
end
