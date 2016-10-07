require './config/aws'

class S3Storage
  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

  def self.put(path, data)
    S3_BUCKET.object(path).put(body: data)
  end

  def self.get(path)
    S3_BUCKET.object(path).get.body.read
  end

  def self.url_for(path)
    S3_BUCKET.object(path).presigned_url(:get, expires_in: 3600)
  end
end
