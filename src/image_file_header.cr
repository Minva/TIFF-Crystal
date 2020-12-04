require "json"

class Tiff::ImageFileHeader
  include JSON::Serializable

  @[JSON::Field(key: "idOrder")]
  getter id_order : String

  getter offset : UInt32 = 0

  @[JSON::Field(key: "versionNumber")]
  getter version_number : UInt16 = 0

  def initialize(data : Bytes)
    raise "TIFF Image File Header size < 8 bytes" if data.size < 8
    @id_order = String.new data[0..1]
    raise "TIFF Invalid Identification Byte Order" unless self.byte_order?
    raise "TIFF Motorola byte onder unsupported" if @id_order == MOTOROLA_BYTE_ORDER
    @version_number = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @offset = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end

  def initialize(@id_order : String, @version_number : UInt16, @offset : UInt32)
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

  def bytes : Bytes    
    data = Bytes.new 8
    ptrIdOrder = @id_order.to_unsafe.as Pointer(UInt8)
    ptrOffset = @offset.to_unsafe.as Pointer(UInt8)
    ptrVersionNumber = @version_number.to_unsafe.as Pointer(UInt8)
    # TODO : Clean this Ugly Block
    data[0] = ptrIdOrder[0]
    data[1] = ptrIdOrder[1]
    data[2] = ptrVersionNumber[0]
    data[3] = ptrVersionNumber[1]
    data[4] = ptrOffset[0]
    data[5] = ptrOffset[1]
    data[6] = ptrOffset[2]
    data[7] = ptrOffset[3]
    return data
  end
end
