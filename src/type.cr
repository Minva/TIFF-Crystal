require "json"

class Tiff::Type
  def self.convert_to_s(tag : UInt16) : String
   case tag
   when 1 then return "BYTE"       # UInt8
   when 2 then return "ASCII"      # UInt8 as String
   when 3 then return "SHORT"      # UInt16
   when 4 then return "LONG"       # UInt32
   when 5 then return "RATIONAL"   # UInt64
   when 6 then return "SBYTE"      # Int8
   when 7 then return "UNDEFINED"  # Bytes
   when 8 then return "SSHORT"     # Int16
   when 9 then return "SLONG"      # Int32
   when 10 then return "SRATIONAL" # Int64
   when 11 then return "FLOAT"     # Float32
   when 12 then return "DOUBLE"    # Float64
   else
    raise "TIFF DirectoryEntry Type Unsuppoted"
   end
  end

  def self.from_json(value : JSON::PullParser) : UInt16
    # INFO : Maybe Doesn't work
    value.try(&.read_int ).try(&.to_i)
  end

  def self.to_json(value : UInt16, json : JSON::Builder)
    json.string self.convert_to_s value
  end
end
