require "compress/zlib"
require "./image"
require "./pixel_format"
require "./resolution"

class Tiff::Tile
  @pixels : Bytes | Nil = nil

  property pixel_fomat : PixelFormat = PixelFormat.new PixelFormatOrder::RGB, 1
  property resolution : Resolution = Resolution.new 0, 0

  def initialize(file : File, @descriptions : Hash(UInt16, UInt32), offset : UInt32, byteCounts : UInt32)
    raise "Tiff Tile Descriptons TAG_COMPRESSION missing" unless @descriptions[TAG_COMPRESSION]?
    file.pos = offset
    @pixels = self.inflate Bytes.new (byteCounts.to_i) { file.read_byte.not_nil! }
  end

  # def initialize(@data : Bytes, @descriptions : Hash(UInt16,  ), @offset : UInt32, @byteCounts : UInt32)
  # end

  #############################################################################
  # Private Method of Class
  #############################################################################

  private def inflate : Bytes
    case @descriptions[TAG_COMPRESSION]
    when 1
      @pixels = data
    when 8
      reader = Compress::Zlib::Reader.new IO::Memory.new data
      # INFO : this line cause issue of performance cause convert an array to slice
      bytes = reader.gets_to_end.bytes
      return Bytes.new (bytes.size) { |index| bytes[index] }
    else
      raise "Tiff Tile Compression Format Unsuported"
    end
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def to_image : Image
    Image.new @pixels.not_nil!, @resolution, @pixel_fomat
  end
end
