require "uri"
require "./alias"
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
  # The ID = 0 of metadata is File and > 0 is SubFile/NewSubFile
  @metadata : MetaDataType = MetaDataType.new

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

  def initialize(image : Image)
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
    # TODO : Refactor 'cause I'vnt undertand how work the SubFile/NewSubFile system
    subFileId = 0_u32
    @ifds.each do |ifd|

      @metadata[subFileId] = {} of UInt16 => Array(String) | Array(Bytes) | Array(UInt16) | Array(UInt32) | Array(UInt64) | Array(Int8) | Array(Int16) | Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64)




      ifd.directory_entries.each do |dirEntry|
        next if dirEntry.tag == 0
        self.tag_call_to_function subFileId, dirEntry
      end
      subFileId += 1
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
  private def value_section_to_data(dirEntry : DirectoryEntry, section : Bytes)
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
      else
        raise "Tiff Value Section Data Type Unknow"
      end
    {% end %}
  end

  {% begin %}
    {% for description in DESCRIPTIONS %}
      {% suffix = "" %}
      {% for name in description["name"] %}
        {% suffix = suffix + "_#{ name.id }" %}
      {% end %}
      private def load_value{{ suffix.id }}(subFileId : UInt32, dirEntry : DirectoryEntry)
        # TODO : raise if the type is wrong
        # dirEntry.type
        # TODO : Refactor this code as shit
        if dirEntry.count < 2
          offset = dirEntry.offset
          ptrValue = pointerof(offset).as Pointer(UInt8)
          bytes = Bytes.new 4 { |index| ptrValue[index] }
          data = self.value_section_to_data dirEntry, bytes
          @metadata[subFileId][dirEntry.tag] = data
        else
          nbrByte = dirEntry.count * self.type_sizeof dirEntry.type
          @file.not_nil!.pos = dirEntry.offset
          bytes = Bytes.new (nbrByte.to_i) { @file.not_nil!.read_byte.not_nil! }
          data = self.value_section_to_data dirEntry, bytes
          @metadata[subFileId][dirEntry.tag] = data
        end
      end
    {% end %}

    private def tag_call_to_function(subFileId : UInt32, dirEntry : DirectoryEntry)
      case dirEntry.tag
      {% for description in DESCRIPTIONS %}
        {% suffix = "" %}
        {% for name in description["name"] %}
          {% suffix = suffix + "_#{ name.id }" %}
        {% end %}
        when {{ description["tag"] }} then self.load_value{{ suffix.id }}(subFileId, dirEntry)
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

  def tiles? : Boolean
    # TODO : Mean if the tiff contents tiles 
  end

  def tiles : UInt16
    # TODO : Reaturn the number tiles content 
  end

  # TODO : Create a function for create a certain number of tiles and size of the tilse

  def tile(idSubFile : UInt32, idTile : UInt32)
    # INFO :
  end

  def tile(idTile : UInt32) : Tile
    # INFO : By default get the first file describe, for get a spetific tile
    # form a certain SubFile/NewSubFile see tile(idSubFile : UInt32, idTile : UInt32)
    # TODO : Develop again this function for check if already load

    ###########################################################################
    # Bullshit Test
    ###########################################################################
    
    puts "============================================================="
    # print @metadata

    offset = @metadata[0][324][0].as UInt32
    byteCounts = @metadata[0][325][0].as UInt32
    compression = 8_u16 # Flag
    Tile.new @file.not_nil!, compression, offset, byteCounts
  end

  def save(path : String)
    # TODO : save as file
    # self.to_package
  end

  def to_package : Bytes
    # TODO : Convert in file already for save as File
    @header = ImageFileHeader.new INTEL_BYTE_ORDER, 42, 8 if @header == nil
    # @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new
  
    Bytes.new 1
  end
end

###############################################################################
# TESTING PART
###############################################################################

imgTiff = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
tile = imgTiff.tile 0
image = tile.to_image
newTiff = Tiff::Tiff.new image
data = newTiff.to_package

puts "end"
