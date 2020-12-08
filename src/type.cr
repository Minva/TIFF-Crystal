require "json"
require "./macro_constants"

class Tiff::Type
  def self.convert_to_s(tag : UInt16) : String
    {% begin %}
      case tag
      {% for type in TYPES%}
        when {{ type[0] }} then return {{ type[2] }}      
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
end
