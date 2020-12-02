require "./DirectoryEntry"

class Tiff::ImageFileDirectory
  @file : File

  getter directory_entries : Array(DirectoryEntry)
  getter number_entries : UInt16
  getter offset : UInt32 = 0_u32

  def initialize(@file : File, @offset : UInt32)
    @file.pos = @offset
    data = Bytes.new 2 { @file.read_byte.not_nil! }
    @number_entries = (data.to_unsafe.as Pointer(UInt16))[0]
    @directory_entries = Array(DirectoryEntry).new @number_entries do
      DirectoryEntry.new Bytes.new 12 { @file.read_byte.not_nil! }
    end
    return if @directory_entries[@number_entries - 1].tag == 0
    @offset = (@file.gets(4).not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end
end
