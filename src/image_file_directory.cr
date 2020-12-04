require "json"
require "./directory_entry"

class Tiff::ImageFileDirectory
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @file : File

  @[JSON::Field(key: "directoryEntries")]
  getter directory_entries : Array(DirectoryEntry)

  @[JSON::Field(key: "numberEntries")]
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
    @offset = ((Bytes.new 4 { @file.read_byte.not_nil! }).to_unsafe.as Pointer(UInt32))[0]
  end
end
