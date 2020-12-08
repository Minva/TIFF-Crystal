require "json"

class Tiff::ImageFileHeader
  include JSON::Serializable

  property offset : UInt32 = 0

  @[JSON::Field(key: "idOrder")]
  getter id_order : Bytes

  @[JSON::Field(key: "versionNumber")]
  getter version_number : UInt16 = 0

  def initialize(data : Bytes)
    raise "TIFF Image File Header size < 8 bytes" if data.size < 8
    @id_order = Bytes.new 2 { |index| data[index] }
    raise "TIFF Invalid Identification Byte Order" unless self.byte_order?
    raise "TIFF Motorola byte onder unsupported" if @id_order == MOTOROLA_BYTE_ORDER
    @version_number = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @offset = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end

  def initialize(@id_order : Bytes, @version_number : UInt16, @offset : UInt32)
  end

  #############################################################################
  # Private Method of Class
  #############################################################################

  private def byte_order?
    @id_order == INTEL_BYTE_ORDER || @id_order == MOTOROLA_BYTE_ORDER
  end

  #############################################################################
  # Public Method of Class
  #############################################################################

  def to_data : Array(UInt8)    
    ptrOffset = pointerof(@offset).as Pointer(UInt8)
    ptrVersionNumber = pointerof(@version_number).as Pointer(UInt8)
    # TODO : Clean this Ugly Block
    data = Array(UInt8).new
    data << @id_order[0]
    data << @id_order[1]
    data << ptrVersionNumber[0]
    data << ptrVersionNumber[1]
    data << ptrOffset[0]
    data << ptrOffset[1]
    data << ptrOffset[2]
    data << ptrOffset[3]
    return data
  end
end
