require "./pixel_format"
require "./resolution"

class Tiff::Image
  property pixels : Bytes
  property pixel_format : PixelFormat
  property resolution : Resolution

  def initialize
    # INFO : Set by deflaut value
    @pixels = Byte.new
    @pixel_format = PixelFormat.new PixelFormatOrder::RGB, 8
    @resolution = Resolution.new 0, 0
  end

  def initialize(@pixels : Bytes, @resolution : Resolution, @pixel_format : PixelFormat)
  end

  ##############################################################################
  # Public Method of Class
  ##############################################################################

  def flush
    # TODO : Data Flush form @data
  end

  def to_tiff : Tiff
    Tiff.new @data, @resolution, @pixel_format
  end
end
