require "json"
require "./macro_constants"

class Tiff::Type
  def self.convert_to_s(tag : UInt16) : String
    {% begin %}
      case tag
      {% for type in TYPES %}
        when {{ type[0] }} then return {{ type[2] }}
      {% end %}
      else
        raise "TIFF DirectoryEntry Type Unsuppoted"
      end
    {% end %}
  end

  def self.convert_to_type(tag : String) : UInt16
    {% begin %}
      case tag
      {% for type in TYPES %}
        when {{ type[2] }} then return {{ type[0] }}_u16
      {% end %}
      else
        raise "TIFF DirectoryEntry Type Unsuppoted"
      end
    {% end %}
  end

  def self.from_json(value : JSON::PullParser) : UInt16
    # INFO : Maybe Doesn't work
    value.try(&.read_int ).try(&.to_i)
  end

  def self.to_json(value : UInt16, json : JSON::Builder)
    json.string self.convert_to_s value
  end

  def self.sizeof(type : UInt16)
    case type
    when 1, 2, 6, 7 then return 1
    when 3, 8 then return 2
    when 4, 9, 11 then return 4
    when 5, 10, 12 then return 8
    else
      raise "TIFF DirectoryEntry Type Unsuppoted"
    end
  end
end
