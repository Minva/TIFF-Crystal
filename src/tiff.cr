require "./directory_entry"
require "./image_file_directory"
require "./image_file_header"
require "./macro_constants"
require "./tile"

class Tiff::Tiff
  @file : File | Nil = nil
  @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new
  @metadata = Hash(UInt16, String | Array(Bytes) | Array(UInt16) | Array(UInt32) | Array(UInt64) | Array(Int8) | Array(Int16) | Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64)).new

  getter header : ImageFileHeader | Nil = nil

  def initialize(path : String)
    @file = File.new path
    @header = ImageFileHeader.new Bytes.new 8 { @file.not_nil!.read_byte.not_nil! }
    self.load_image_file_directories
    self.load_metadata
  end

  def initialize(uri : URI)
    raise "TIFF load from URI not supported"
  end

  #############################################################################
  # Private method of class
  #############################################################################

  private def load_image_file_directories
    offset = @header.not_nil!.offset
    loop do
      imgFDir = ImageFileDirectory.new @file.not_nil!, offset
      @ifds << imgFDir
      break if imgFDir.offset == 0
      offset = imgFDir.offset
    end
  end

  private def load_metadata
    @ifds.each do |ifd|
      ifd.directory_entries.each do |dirEntry|
        next if dirEntry.tag == 0
        self.tag_call_to_function dirEntry
      end
    end
  end

  private def type_sizeof(type : UInt16)
    case type
    when 1, 2, 6, 7 then return 1
    when 3, 8 then return 2
    when 4, 9, 11 then return 4
    when 5, 10, 12 then return 8
    else
      raise "TIFF DirectoryEntry Type Unsuppoted"
    end
  end

  # INFO : This fonction convert a section of data in Array on certain type
  private def value_section_to_data(dirEntry : DirectoryEntry, section : Array(UInt8))
    {% begin %}
      {%
        types = [
          [ 1, UInt32 ], [ 2, String ], [ 3, UInt16 ], [ 4, UInt32 ],
          [ 5, UInt64 ], [ 6, Int8 ], [ 7, Bytes ], [ 8, Int16 ],
          [ 9, Int32 ], [ 10, Int64 ], [ 11, Float32 ], [ 12, Float64 ]
        ]
      %}
      case dirEntry.type
      {% for elem in types %}
        when {{ elem[0] }}
        {% if elem[1] == String %}
          return String.new section.to_unsafe.as Pointer(UInt8)
        {% else %}
          data = [] of {{ elem[1] }}
          itr = 0
          ptr = section.to_unsafe.as Pointer({{ elem[1] }})
          while itr < dirEntry.count
            data << ptr[itr]
            itr = itr + 1
          end
          return data
        {% end %}
      {% end %}
      end
    {% end %}
  end

  {% begin %}
    {% for description in DESCRIPTIONS %}
      {% suffix = "" %}
      {% for name in description["name"] %}
        {% suffix = suffix + "_#{ name.id }" %}
      {% end %}
      private def load_value{{suffix.id}}(dirEntry : DirectoryEntry)
        # TODO : raise if the type is wrong
        # dirEntry.type
        if dirEntry.count < 2
          value = dirEntry.offset
          ptrValue = pointerof(value).as Pointer(UInt8)
          bytes = Array(UInt8).new 4 { |index| ptrValue[index] }
          data = self.value_section_to_data dirEntry, bytes
        else
          nbrByte = dirEntry.count * self.type_sizeof dirEntry.type
          @file.not_nil!.pos = dirEntry.offset
          bytes = Array(UInt8).new nbrByte do
            @file.not_nil!.read_byte.not_nil!
          end
          data = self.value_section_to_data dirEntry, bytes
          @metadata[dirEntry.tag] = data.not_nil!
        end
      end
    {% end %}

    private def tag_call_to_function(dirEntry : DirectoryEntry)
      case dirEntry.tag
      {% for description in DESCRIPTIONS %}
        {% suffix = "" %}
        {% for name in description["name"] %}
          {% suffix = suffix + "_#{ name.id }" %}
        {% end %}
        when {{description["tag"]}} then self.load_value{{suffix.id}}(dirEntry)
      {% end %}
      else
        raise "TIFF DirectoryEntry Tag Unsuppoted"
      end
    end

    private def tag_to_s(tag : UInt16) : String
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
    end
  {% end %}

  #############################################################################
  # It a Huge Messy & code write as shit
  #############################################################################

  private def type_to_s(value : UInt16)
    case value
    when 1 then return "BYTE" # 8-bit unsigned integer.
    when 2 then return "ASCII" # 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero).
    when 3 then return "SHORT" # 16-bit (2-byte) unsigned integer
    when 4 then return "LONG" # 32-bit (4-byte) unsigned integer
    when 5 then return "RATIONAL" # Two LONGs: the first represents the numerator of a fraction; the second, the denominator.
    when 6 then return "SBYTE" # An 8-bit signed (twos-complement) integer.
    when 7 then return "UNDEFINED" # An 8-bit byte that may contain anything, depending on the definition of the field.
    when 8 then return "SSHORT" # A 16-bit (2-byte) signed (twos-complement) integer.
    when 9 then return "SLONG" # A 32-bit (4-byte) signed (twos-complement) integer.
    when 10 then return "SRATIONAL" # Two SLONG’s: the first represents the numerator of a fraction, the second the denominator.
    when 11 then return "FLOAT" # Single precision (4-byte) IEEE format.
    when 12 then return "DOUBLE" # Double precision (8-byte) IEEE format.
    end
  end

  #############################################################################
  # Loader Value form Tag
  #############################################################################

  private def load_compression(type : UInt16, count : UInt32, offset : UInt32)
    # ref doc : https://www.liquisearch.com/tagged_image_file_format/flexible_options/tiff_compression_tag
    # ref doc : https://www.awaresystems.be/imaging/tiff/tifftags/compression.html
    case type
    when 1 then "uncompressed"
    when 2 then "CCITT Group 3"
    when 3 then "CCITT T.4"
    when 4 then "CCITT T.6"
    when 5 then "LZW" # Lempel-Ziv & Welch algorithm
    when 6 then "JPEG Obsolete"
    when 7 then "JPEG New Style"
    when 8 then "Deflate Official Version" # Adobe Style
    when 9 then "JBIG, per ITU-T T.85"
    when 10 then "JBIG, per ITU-T T.43"
    when 32766 then "NeXT RLE"
    when 32773 then "PackBits compression" # Macintosh RLE
    when 32809 then "ThunderScan RLE"
    when 32895 then "RasterPadding in CT or MP"
    when 32896 then "RLE for LW"
    when 32897 then "RLE for HC"
    when 32898 then "RLE for BL"
    when 32946 then "PKZIP Style Deflate Encoding"
    when 32947 then "Kodak DCS"
    when 34661 then "JBIG"
    when 34712 then "JPEG2000"
    when 34713 then "Nikon NEF Compressed"
    else
    end
  end

  #############################################################################
  # Public method of class
  #############################################################################

  def tile(id : UInt32)
    offset = @metadata[324][0].as UInt32
    byteCounts = @metadata[325][0].as UInt32
    # @file : File, @compression : UInt16, @offset : UInt32, @byteCounts : UInt32
    puts byteCounts
    ti = Tile.new @file.not_nil!, 0, offset, byteCounts
  end
end

###############################################################################
# TESTING PART
###############################################################################

image = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
image.tile 0

puts "end"
