require "./pixel_format"
require "./resolution"

class Tiff::Image
  @data : Bytes
  @height : UInt32
  @width : UInt32

  def initialize
    @height = 0
    @width = 0
  end

  def initialize(@data : Bytes, resolution : Resolution, pixelFormat : PixelFormat)
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def to_tiff
    
  end
end