require "compress/zlib"
require "./alias"
require "./image"
require "./pixel_format"
require "./resolution"

class Tiff::Tile
  @pixels : Bytes | Nil = nil

  property pixel_fomat : PixelFormat = PixelFormat.new PixelFormatOrder::RGB, 1
  property resolution : Resolution = Resolution.new 0, 0

  def initialize(file : File, @descriptions : Description, offset : UInt32, byteCounts : UInt32, fullSize : Int32)
    raise "Tiff Tile Descriptons TAG_COMPRESSION missing" unless @descriptions[TAG_COMPRESSION]?
    file.pos = offset
    data = Bytes.new byteCounts.to_i
    bytes_read = file.read data
    @pixels = self.inflate IO::Memory.new(data), fullSize
  end

  # def initialize(@data : Bytes, @descriptions : Description, @offset : UInt32, @byteCounts : UInt32)
  # end

  ##############################################################################
  # Private Method of Class
  ##############################################################################

  private def inflate(data : IO::Memory, fullSize : Int32) : Bytes
    case @descriptions[TAG_COMPRESSION]
    when 1
      @pixels = Bytes.new data.buffer, data.size
    when 8
      reader = Compress::Zlib::Reader.new data
      buffer = Bytes.new fullSize
      reader.read_fully buffer
      return buffer
    else
      raise "Tiff Tile Compression Format Unsuported"
    end
  end

  ##############################################################################
  # Public Method of Class
  ##############################################################################

  def to_image : Image
    Image.new @pixels.not_nil!, @resolution, @pixel_fomat
  end
end
