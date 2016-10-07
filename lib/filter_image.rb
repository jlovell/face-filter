require 'open-uri'
require 'rmagick'

module FilterImage
  def self.from_url(url, **options)
    call Magick::Image.from_blob(open(url).read).first, options
  end

  def self.from_blob(blob, **options)
    call Magick::Image.from_blob(blob).first, options
  end

  def self.from_file(path, **options)
    call Magick::Image.read(path).first, options
  end

  def self.overlayed_call(source, letter: nil)
    dimensions = [source.columns, source.rows]

    overlay ||= Magick::Image.read("assets/layers/lgbtqa.png").first
    if dimensions != [overlay.columns, overlay.rows]
      overlay = overlay.resize_to_fill(*dimensions)
    end
    source.composite!(overlay.negate, Magick::CenterGravity, Magick::OverlayCompositeOp)

    return source unless letter

    letter = Magick::Image.read("assets/layers/#{letter.downcase}.png").first
    if dimensions != [letter.columns, letter.rows]
      letter = letter.resize_to_fill(*dimensions)
    end

    colored = Magick::Image.new(*dimensions) { self.background_color = '#e74c3c' }
    colored.composite!(letter.negate, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

    source.composite!(colored, Magick::CenterGravity, Magick::OverCompositeOp)
    source
  end

  def self.call(source, letter: 'lgbtqa')
    dimensions = [source.columns, source.rows]

    letter = Magick::Image.read("assets/layers/#{letter.downcase}.png").first
    if dimensions != [letter.columns, letter.rows]
      letter = letter.resize_to_fill(*dimensions)
    end
    source.composite!(letter, Magick::CenterGravity, Magick::OverCompositeOp)
    source
  end
end
