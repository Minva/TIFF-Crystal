require "compress/zlib"

class Tiff::Tile
  @data : Bytes

  def initialize(@file : File, @compression : UInt16, @offset : UInt32, @byteCounts : UInt32)
    @file.pos = @offset
    @data = Bytes.new (@byteCounts.to_i) { @file.read_byte.not_nil! }
    reader = Compress::Zlib::Reader.new IO::Memory.new @data
    inflate = reader.gets_to_end.bytes

    puts inflate.size
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def to_image : Tiff::Image
  end
end
