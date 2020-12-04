require "compress/zlib"
require "./image"
require "./pixel_format"
require "./resolution"

class Tiff::Tile
  @pixels : Array(UInt8) | Nil = nil

  property pixel_fomat : PixelFormat = PixelFormat.new PixelFormatOrder::RGB, 1
  property resolution : Resolution = Resolution.new 0, 0

  def initialize(@file : File, @compression : UInt16, @offset : UInt32, @byteCounts : UInt32)
    @pixels = self.inflate.not_nil!
    puts inflate.size
  end

  #############################################################################
  # Private Method of Class
  #############################################################################

  private def inflate : Array(UInt8)
    @file.pos = @offset
    data = Bytes.new (@byteCounts.to_i) { @file.read_byte.not_nil! }
    case @compression
    # when 1
    when 8
      reader = Compress::Zlib::Reader.new IO::Memory.new data
      return reader.gets_to_end.bytes
    else
      raise "Tiff Tile Compression Format Unsuported"
    end
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def to_image : Tiff::Image
    Image.new @pixels, @resolution, @pixel_fomat
  end
end
