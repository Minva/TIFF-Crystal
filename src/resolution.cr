struct Tiff::Resolution
  @height : UInt32
  @width : UInt32

  def initialize(@height : UInt32, @width : UInt32)
  end
end
