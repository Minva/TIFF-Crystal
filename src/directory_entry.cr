require "json"
require "./tag"
require "./type"

class Tiff::DirectoryEntry
  include JSON::Serializable

  @[JSON::Field(converter: Tiff::Tag)]
  getter tag : UInt16
 
  @[JSON::Field(converter: Tiff::Type)]
  getter type : UInt16

  getter count : UInt32
  getter offset : UInt32

  def initialize(data : Bytes)
    raise "TIFF DirectoryEntry size < 12 bytes" if data.size < 12
    @tag = (data[0..1].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @type = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @count = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
    @offset = (data[8..11].not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end
end
