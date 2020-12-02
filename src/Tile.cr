class Tiff::Tile
  @data : Array(UInt8) 

  def initialize(@file : File, @compression : UInt16, @offset : UInt32, @byteCounts : UInt32)
    @file.pos = @offset

    @data = Array(UInt8).new @byteCounts do
      @file.read_byte.not_nil!
    end
  end
end
