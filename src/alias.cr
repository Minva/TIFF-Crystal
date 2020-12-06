module Tiff
  alias MetaDataType = Hash(UInt32, Hash(UInt16, Array(String) | Array(Bytes) | Array(UInt16) | Array(UInt32) | Array(UInt64) | Array(Int8) | Array(Int16) | Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64)))
end
