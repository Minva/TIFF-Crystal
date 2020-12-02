class Tiff::ImageFileHeader
  getter id_order : String
  getter offset : UInt32 = 0
  getter version_number : UInt16 = 0

  private def byte_order?
    @id_order == INTEL_BYTE_ORDER || @id_order == MOTOROLA_BYTE_ORDER
  end

  def initialize(data : Bytes)
    raise "TIFF Image File Header size < 8 bytes" if data.size < 8
    @id_order = String.new data[0..1]
    raise "TIFF Invalid Identification Byte Order" unless self.byte_order?
    raise "TIFF Motorola byte onder unsupported" if @id_order == MOTOROLA_BYTE_ORDER
    @version_number = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
    @offset = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
  end
end
