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
require "./type"

class Tiff::Tiff
  @file : File | Nil = nil
  @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new
  # Array cause SubFile/NewSubFile
  @description : Array(Description) = Array(Description).new
  # The ID = 0 of metadata is File and > 0 is SubFile/NewSubFile
  @metadata : MetaDataType = MetaDataType.new

  @image : Image?

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

  def initialize(@image : Image)
    # TODO: Rebuild a image on Tiff Format
  end

  ##############################################################################
  # Private method of class
  ##############################################################################

  private def load_image_file_directories
    offset = @header.not_nil!.offset
    loop do
      imgFDir = ImageFileDirectory.new @file.not_nil!, offset
      # puts "-------------------------------------------------"
      # puts imgFDir.to_pretty_json
      @ifds << imgFDir
      break if imgFDir.offset == 0
      offset = imgFDir.offset
    end
  end

  private def load_metadata
    # TODO : Refactor 'cause I'vnt undertand how work the SubFile/NewSubFile system
    subFileId = 0_u32
    @ifds.each do |ifd|
      @metadata[subFileId] = {} of UInt16 => Array(String) | Array(Bytes) | Array(UInt8) | Array(UInt16) | Array(UInt32) | Array(UInt64) | Array(Int8) | Array(Int16) | Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64)
      ifd.directory_entries.each do |dirEntry|
        next if dirEntry.tag == 0
        self.tag_call_to_function subFileId, dirEntry
      end
      subFileId += 1
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
        # with this macro get this Error: undefined macro method 'TypeNode#convert_to_type'
        # {--% condition = "" %--}
        # {--% insertOr = false %--}
        # {--% for type in description["type"] %--}
        #   {--% if insertOr %--}
        #     {--% condition += " || " %--}
        #   {--% end %--} 
        #   {--% condition += "dirEntry.type == #{ Type.convert_to_type description["name"] }" %--}
        # {--% end %--}
        # raise "Tiff load value type #{ Type.convert_to_tag description["name"] } invalid" unless {--{ condition.id }--}
        # TODO : Refactor this code as shit
        if dirEntry.count < 2
          offset = dirEntry.offset
          ptrValue = pointerof(offset).as Pointer(UInt8)
          bytes = Bytes.new 4 { |index| ptrValue[index] }
          data = self.value_section_to_data dirEntry, bytes
          @metadata[subFileId][dirEntry.tag] = data
        else
          nbrByte = dirEntry.count * Type.sizeof dirEntry.type
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

  ##############################################################################
  # Public method of class
  ##############################################################################

  # INFO : This macro auto-gen the public methode for each tag
  {% begin %}
    {% for description in DESCRIPTIONS %}
      {% nameFunction = "" %}
      {% insertUnderscore = false %}
      {% for name in description["name"] %}
        {% if insertUnderscore == true %}
          {% nameFunction += "_" %}
        {% end %}
        {% nameFunction += "#{ name.id }" %}
        {% insertUnderscore = true %}
      {% end %}

      def {{ nameFunction.id }}(idSubFile : UInt32)
      end

      def {{ nameFunction.id }}=(idSubFile : UInt32)
      end

    {% end %}
  {% end %}

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
    raise "Tiff MetaData File or SubFile/NewSubFile Missing" unless @metadata[0]?
    raise "Tiff MetaData Key : TAG_TILE_OFFSETS" unless @metadata[0][TAG_TILE_OFFSETS]?
    raise "Tiff MetaData Key : TAG_TILE_BYTE_COUNTS" unless @metadata[0][TAG_TILE_BYTE_COUNTS]?
    raise "Tiff MetaData Key : TAG_COMPRESSION" unless @metadata[0][TAG_COMPRESSION]?
    offset = @metadata[0][TAG_TILE_OFFSETS][idTile].as UInt32
    byteCounts = @metadata[0][TAG_TILE_BYTE_COUNTS][idTile].as UInt32
    ############################################################################
    # INFO : New Version 
    ############################################################################
    description = Description.new
    description[TAG_COMPRESSION] = @metadata[0][TAG_COMPRESSION][0].as UInt16
    # TODO : Next time check if key?
    description[TAG_PREDICTOR] = @metadata[0][TAG_PREDICTOR][0].as UInt16
    Tile.new @file.not_nil!, description, offset, byteCounts
  end

  def save(path : String)
    File.write path, self.to_package, mode: "w"
  end

  ##############################################################################
  # PACKAGING 
  ##############################################################################

  def to_package : Bytes
    # Management of the simple case with only one SubFile
    nextFreeOffset = 0
    nextFreeOffset += dataHeader.size
    nextFreeOffset += 2 + (virtualIFD.number_entries * 12 + 4)
    # Loop do for each next Free Offset, actually the code mannage only one
    virtualIFD[indexBPS.to_u32].offset = (nextFreeOffset).to_u32
    nextFreeOffset += 6
    virtualIFD[index.to_u32].offset = (nextFreeOffset).to_u32
    virtualIFD.offset = 0
    # Calculation of the next offset free 
    dataPackage = dataHeader
    dataPackage.concat virtualIFD.to_data
    val = 8_u16
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[0] ]
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[1] ]
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[0] ]
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[1] ]
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[0] ]
    dataPackage.concat [ (pointerof(val).as Pointer(UInt8))[1] ]
    img = @image.not_nil!.pixels
    dataPackage.concat Array(UInt8).new (img.size) { |index| img[index] }
    Bytes.new (dataPackage.size) { |index| dataPackage[index] }

    ############################################################################
    ############################################################################
    ############################################################################

    # INFO optimized for COG
    # TODO lodad @metadata if @description in empty
    ############################################################################
    # TODO : First generate the chain of IFD
    ############################################################################
    listIFD = [] of ImageFileDirectory
    listOffset = {} of Int32 => Hash(UInt16, Int32)
    @description.each_index do |index|
      listIFD << ImageFileDirectory.new
      # TODO : Check if in the @description
      subIndex : Int32 = 0
      @description[index].each do |tag, value|
        type = Type.which value
        # TODO : Define the count
        count = 1
        value.is_a? Array
        # TODO : Define the value
        offsetValue = 0
        # If it's an offset
        listOffset[index] = { tag => subIndex }
        listIFD << DirectoryEntry.new tag, type, count, offsetValue
        subIndex += 1
      end
    end
    ############################################################################
    # Create a tmp Array for stack the bytes of the file
    ############################################################################
    startOffset = 8
    header = ImageFileHeader.new INTEL_BYTE_ORDER, 42, startOffset
    dataHeader = header.to_data
    dataPackage = dataHeader
    dataPackage.concat virtualIFD.to_data

    ############################################################################
    # TODO : Second management of offset
    ############################################################################
    # INFO calculation of number offset take all IFDs
    numberOffsets = 0
    listIFD.each do |item|
      numberOffsets += 2 # 2 Bytes for the numberEntries
      numberOffsets += item.number_entries * 12
      numberOffsets += 4 # 4 Bytes for the numberEntries
    end



    ############################################################################
    # TODO : Third place the data
    ############################################################################

  end
end

################################################################################
# TESTING PART
################################################################################

imgTiff = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
tile = imgTiff.tile 0
image = tile.to_image
newTiff = Tiff::Tiff.new image
newTiff.compression = 8
# data = newTiff.to_package
newTiff.save "/Users/nikolaiilodenos/Desktop/AAA.tiff"
