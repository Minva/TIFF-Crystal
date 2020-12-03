enum Tiff::PixelFormatOrder
  RGB
  RGBA
end

struct Tiff::PixelFormat
  @format : PixelFormatOrder
  @bytes_per_pixel : UInt8

  def initialize(@format : PixelFormatOrder, @bytes_per_pixel : UInt8)
  end
end
