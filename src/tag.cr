require "json"
require "./macro_constants"

class Tiff::Tag
  def self.convert_to_s(tag : UInt16) : String
    {% begin %}
    case tag
    {% for description in DESCRIPTIONS %}
      {% nameTag = "" %}
      {% for name in description["name"] %}
        {% nameTag = nameTag + "#{ name.titleize.id }" %}
      {% end %}
      when {{description["tag"]}} then return "{{nameTag.id}}"
    {% end %}
    else
      raise "TIFF DirectoryEntry Tag Unsuppoted"
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
