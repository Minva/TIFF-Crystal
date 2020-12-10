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

  #############################################################################
  # Private method of class
  #############################################################################

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
    raise "Tiff MetaData File or SubFile/NewSubFile Missing" unless @metadata[0]?
    raise "Tiff MetaData Key : TAG_TILE_OFFSETS" unless @metadata[0][TAG_TILE_OFFSETS]?
    raise "Tiff MetaData Key : TAG_TILE_BYTE_COUNTS" unless @metadata[0][TAG_TILE_BYTE_COUNTS]?
    raise "Tiff MetaData Key : TAG_COMPRESSION" unless @metadata[0][TAG_COMPRESSION]?
    offset = @metadata[0][TAG_TILE_OFFSETS][idTile].as UInt32
    byteCounts = @metadata[0][TAG_TILE_BYTE_COUNTS][idTile].as UInt32
    compression = @metadata[0][TAG_COMPRESSION][0].as UInt16
    Tile.new @file.not_nil!, compression, offset, byteCounts
  end

  def save(path : String, rrr)
    File.write path, self.to_package(rrr), mode: "w"
  end

  #############################################################################
  # PACKAGING 
  #############################################################################

  def to_package(rrr) : Bytes
    # TODO : Convert in file already for save as File
    header = ImageFileHeader.new INTEL_BYTE_ORDER, 42, 8
    # @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new
    # Build the IFD first
    # Use the relative postition before convertion in absolut
    # virtualIFD
    height = 1024_u32
    witdh = 1024_u32
    index = 0
    # Need to coding a standar builder of DirectoryEntry
    ###########################################################################
    # BUILD IMAGE FILE DIRECTORY
    ###########################################################################    
    virtualIFD = ImageFileDirectory.new
    virtualIFD << DirectoryEntry.new TAG_IMAGE_WIDTH, TYPE_SHORT, 1, 1024
    virtualIFD << DirectoryEntry.new TAG_IMAGE_LENGTH, TYPE_SHORT, 1, 1024
    virtualIFD << DirectoryEntry.new TAG_BITS_PER_SAMPLE, TYPE_SHORT, 3, 0 ### NEED an OFFSET
    indexBPS = virtualIFD.number_entries - 1
    virtualIFD << DirectoryEntry.new TAG_COMPRESSION, TYPE_SHORT, 1, 8 # 1 = Uncompressed
    virtualIFD << DirectoryEntry.new TAG_PHOTOMETRIC_INTERPRETATION, TYPE_SHORT, 1, 2 # 2 = RGB
    virtualIFD << DirectoryEntry.new TAG_SAMPLES_PER_PIXEL, TYPE_SHORT, 1, 3 # 3 for each color RGB
    virtualIFD << DirectoryEntry.new TAG_PREDICTOR, TYPE_SHORT, 1, 2
    # TODO : Calculate number of line of the images
    virtualIFD << DirectoryEntry.new TAG_ROWS_PER_STRIP, TYPE_SHORT, 1, 1024
    virtualIFD << DirectoryEntry.new TAG_STRIP_OFFSETS, TYPE_LONG, 1, 0 ### NEED an OFFSET
    index = virtualIFD.number_entries - 1
    byteCounts = rrr.size
    # byteCounts = 1024_u32 * 1024_u32 * 3_u32
    virtualIFD << DirectoryEntry.new TAG_STRIP_BYTE_COUNTS, TYPE_LONG, 1_u32, byteCounts.to_u32
    ###########################################################################
    # Convertion
    ###########################################################################
    # Management of the simple case with only one SubFile
    nextFreeOffset = 0
    dataHeader = header.to_data
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
    dataPackage.concat Array(UInt8).new (rrr.size) { |index| rrr[index] }
    Bytes.new (dataPackage.size) { |index| dataPackage[index] }
  end
end

###############################################################################
# TESTING PART
###############################################################################

imgTiff = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
tile = imgTiff.tile 0
image = tile.to_image
newTiff = Tiff::Tiff.new image
# newTiff.compression = 8
# data = newTiff.to_package
# INFO : Remove the raw just for be work
newTiff.save "/Users/nikolaiilodenos/Desktop/AAA.tiff", tile.raw.not_nil!

###############################################################################
# DEMO Server
###############################################################################

module Layer::RESTful
  class API
    @server : HTTP::Server

    def initialize(@host : String, @port : Int32)
      @server = HTTP::Server.new do |context|
        api = Endpoint.new context
        api.run
      end
    end

    def run
      spawn do
        @server.bind_tcp @host, @port
        @server.listen
      end
    end

    def stop
      @server.close
    end

    def wait_mount
      interval = Time::Span.new(nanoseconds: 1000)
      until @server.listening?
        sleep interval
      end
    end
  end
end

require "bedrock"
require "json"

module Layer::RESTful
  class Endpoint < Bedrock::Routing
    @response : HTTP::Server::Response
    @request : HTTP::Request?
    @startTime : Time::Span = Time.monotonic

    def initialize(@context : HTTP::Server::Context)
      @request = context.request
      @response = context.response
    end

    ############################################################################
    # Private
    ############################################################################

    private def generic_response(message : String, statusCode : Int32)
      @response.content_type = "application/json"
      @response.status_code = statusCode
      cost = (Time.monotonic - @startTime).nanoseconds
      @response.print %({"msg":#{message},"cost":#{cost}})
    end

    private def image
      get "/image/mgrs/50SNF/:id/sentinel-2b/TCI/1606237000.tiff" do |params|
        imgTiff = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"
        tile = imgTiff.tile params["id"].to_u32
        image = tile.to_image
        newTiff = Tiff::Tiff.new image
        # newTiff.compression = 8
        # data = newTiff.to_package
        # INFO : Remove the raw just for be work
        # newTiff.save "/Users/nikolaiilodenos/Desktop/AAA.tiff", tile.raw.not_nil!
        @response.content_type = "image/tiff"
        @response.write newTiff.to_package(tile.raw.not_nil!)
      end
    end

    private def not_found
      self.generic_response "404", 200
    end

    ############################################################################
    # Public
    ############################################################################

    def run
      @startTime = Time.monotonic
      self.image
      dead_links { self.not_found }
    end
  end
end

host = "0.0.0.0"
port = 8080

apiRESTful = Layer::RESTful::API.new host, port
spawn apiRESTful.run
apiRESTful.wait_mount
puts "Service KisharLink run on #{host}:#{port}"
sleep
