require "./directory_entry"
require "./image"
require "./image_file_directory"
require "./image_file_header"
require "./macro_constants"
require "./pixel_format"
require "./resolution"
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

  def initialize(data : Bytes, resolution : Resolution , pixelFormat : PixelFormat)
    # TODO: Rebuild a image on Tiff Format
  end

  #############################################################################
  # Private method of class
  #############################################################################

  private def load_image_file_directories
    offset = @header.not_nil!.offset
    loop do
      imgFDir = ImageFileDirectory.new @file.not_nil!, offset

      puts "-------------------------------------------------"
      puts imgFDir.to_pretty_json
      
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
      case dirEntry.type
      {% for type in TYPES %}
        when {{ type[0] }}
        {% if type[1] == String %}
          return String.new section.to_unsafe.as Pointer(UInt8)
        {% else %}
          data = [] of {{ type[1] }}
          itr = 0
          ptr = section.to_unsafe.as Pointer({{ type[1] }})
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
      private def load_value{{ suffix.id }}(dirEntry : DirectoryEntry)
        # TODO : raise if the type is wrong
        # dirEntry.type
        # TODO : Refactor this code as shit
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
          
          #####################################################################
          # TODO : Solve the Issue for the metadata
          #####################################################################
          
          # @metadata[dirEntry.tag] = data.not_nil!
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
        when {{ description["tag"] }} then self.load_value{{ suffix.id }}(dirEntry)
      {% end %}
      else
        raise "TIFF DirectoryEntry Tag Unsuppoted"
      end
    end
  {% end %}

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

  def crop(xStart : UInt32, yStart : UInt32, xEnd : UInt32, yEnd : UInt32) : Tiff::Image
    # TODO : Crop in Image
    # INFO : Not be sure if I do coding that here 'cause NewSubFile
  end

  def tile(id : UInt32)
    # offset = @metadata[324][0].as UInt32
    # byteCounts = @metadata[325][0].as UInt32
    # # @file : File, @compression : UInt16, @offset : UInt32, @byteCounts : UInt32
    # puts byteCounts
    # Tile.new @file.not_nil!, 8, offset, byteCounts
  end

  def save(path : String)
    # TODO : save as file
    # self.to_package
  end

  def to_package : Bytes
    # TODO : Convert in file already for save as File
    @header = ImageFileHeader.new INTEL_BYTE_ORDER, 42, 8 if @header == nil
    # @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new
  end
end

###############################################################################
# TESTING PART
###############################################################################

imgTiff = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
tile = imgTiff.tile 0

puts "end"
