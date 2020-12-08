require "json"
require "./directory_entry"

class Tiff::ImageFileDirectory
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @file : File?

  @[JSON::Field(key: "directoryEntries")]
  getter directory_entries : Array(DirectoryEntry)

  @[JSON::Field(key: "numberEntries")]
  getter number_entries : UInt16

  property offset : UInt32 = 0_u32

  def initialize
    @directory_entries = Array(DirectoryEntry).new
    @number_entries = @directory_entries.size.to_u16
  end

  def initialize(@file : File, @offset : UInt32)
    @file.not_nil!.pos = @offset
    data = Bytes.new 2 { @file.not_nil!.read_byte.not_nil! }
    @number_entries = (data.to_unsafe.as Pointer(UInt16))[0]
    @directory_entries = Array(DirectoryEntry).new @number_entries do
      DirectoryEntry.new Bytes.new 12 { @file.not_nil!.read_byte.not_nil! }
    end
    return if @directory_entries[@number_entries - 1].tag == 0
    @offset = ((Bytes.new 4 { @file.not_nil!.read_byte.not_nil! }).to_unsafe.as Pointer(UInt32))[0]
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def [](value : UInt32) : DirectoryEntry
    @directory_entries[value]
  end

  def <<(value : DirectoryEntry)
    @directory_entries << value
    @number_entries = @directory_entries.size.to_u16
  end

  def push(value : DirectoryEntry)
    @directory_entries << value
    @number_entries = @directory_entries.size.to_u16
  end

  def to_data : Array(UInt8)
    ptrNumberEntries = pointerof(@number_entries).as Pointer(UInt8)
    ptrOffset = pointerof(@offset).as Pointer(UInt8)
    data = Array(UInt8).new
    data << ptrNumberEntries[0]
    data << ptrNumberEntries[1]
    @directory_entries.each do |directoryEntry|
      data.concat directoryEntry.to_data
    end
    data << ptrOffset[0]
    data << ptrOffset[1]
    data << ptrOffset[2]
    data << ptrOffset[3]
    return data
  end
end
