require './lib/s3_storage'

class Photo
  Storage = S3Storage

  def self.for_id(user_id)
    new(user_id)
  end

  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def store(type, data)
    Storage.put(filepath(type), data)
  end

  def get(type, data)
    Storage.put(filepath(type), data)
  end

  def url(type)
    Storage.url_for(filepath(type))
  end

  private

  def filepath(type)
    "photos/#@user_id/#{type.to_s.downcase}"
  end
end
