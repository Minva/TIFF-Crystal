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

  property offset : UInt32 # Offset or Value

  def initialize(data : Bytes)
    raise "TIFF DirectoryEntry size < 12 bytes" if data.size < 12
    @tag = (data[0..1].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @type = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @count = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
    @offset = (data[8..11].not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end

  def initialize(@tag : UInt16, @type : UInt16, @count : UInt32, @offset : UInt32)
  end

  def to_data : Array(UInt8)
    ptrTag = pointerof(@tag).as Pointer(UInt8)
    ptrType = pointerof(@type).as Pointer(UInt8)
    ptrCount = pointerof(@count).as Pointer(UInt8)
    ptrOffset = pointerof(@offset).as Pointer(UInt8)
    # TODO : Clean this SHIT
    data = Array(UInt8).new
    data << ptrTag[0]
    data << ptrTag[1]
    data << ptrType[0]
    data << ptrType[1]
    data << ptrCount[0]
    data << ptrCount[1]
    data << ptrCount[2]
    data << ptrCount[3]
    data << ptrOffset[0]
    data << ptrOffset[1]
    data << ptrOffset[2]
    data << ptrOffset[3]
    return data
  end
end
