require "json"

# TODO : Write documentation for `Crystal::Tiff`
module Tiff
  VERSION = "0.1.0"

  INTEL_BYTE_ORDER = "II"
  MOTOROLA_BYTE_ORDER = "MM"

  class ImageFileHeader
    getter id_order : String = ""
    getter offset : UInt32 = 0
    getter version_number : UInt16 = 0

    private def byte_order?
      @id_order == INTEL_BYTE_ORDER || @id_order == MOTOROLA_BYTE_ORDER
    end

    def initialize(data : String)
      raise "TIFF Image File Header size < 8 bytes" if data.size < 8
      @id_order = data[0..1]
      raise "TIFF Invalid Identification Byte Order" unless self.byte_order?
      raise "TIFF Motorola byte onder unsupported" if @id_order == MOTOROLA_BYTE_ORDER
      @version_number = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
      @offset = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
    end
  end

  class DirectoryEntry
    include JSON::Serializable

    getter tag : UInt16
    getter type : UInt16
    getter count : UInt32
    getter offset : UInt32

    def initialize(data : String)
      # TODO : Do raise correcly with a string
      # raise "TIFF DirectoryEntry size < 12 bytes" if data.size < 12
      @tag = (data[0..1].not_nil!.to_unsafe.as Pointer(UInt16))[0]
      @type = (data[2..3].not_nil!.to_unsafe.as Pointer(UInt16))[0]
      @count = (data[4..7].not_nil!.to_unsafe.as Pointer(UInt32))[0]
      @offset = (data[8..11].not_nil!.to_unsafe.as Pointer(UInt32))[0]
    end
  end

  class ImageFileDirectory
    @file : File

    getter directory_entries : Array(DirectoryEntry) = Array(DirectoryEntry).new
    getter number_entries : UInt16 = 0
    getter offset : UInt32

    def initialize(@file : File, @offset : UInt32)
      @file.pos = @offset
      @number_entries = (file.gets(2).not_nil!.to_unsafe.as Pointer(UInt16))[0]
      itr = 0
      while itr < @number_entries
        directoryEntry = DirectoryEntry.new @file.gets(12).not_nil!
        @directory_entries << directoryEntry
        itr = itr + 1
      end
      @offset = if @directory_entries[@number_entries - 1].tag == 0
        0_u32
      else
        (@file.gets(4).not_nil!.to_unsafe.as Pointer(UInt32))[0]
      end
    end
  end

  class Tiff
    @file : File | Nil = nil
    @ifds : Array(ImageFileDirectory) = Array(ImageFileDirectory).new

    getter header : ImageFileHeader | Nil = nil

    def initialize(path : String)
      @file = File.new path
      @header = ImageFileHeader.new @file.not_nil!.gets(8).not_nil!
      self.load_image_file_directories
      self.load_metadata
    end
  
    def initialize(uri : URI)
      raise "TIFF load from URI not supported"
    end

    ###########################################################################
    # Private method of class
    ###########################################################################

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
          puts "--------------------------------"
          self.tag_call_to_function dirEntry
          puts self.tag_to_s dirEntry.tag
          puts dirEntry.to_pretty_json
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
    private def value_section_to_data(dirEntry : DirectoryEntry, section : String)
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
            return section
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
      {% descriptions = [
          { "name" => [ "new", "subfile", "type" ], "tag" => 254, "type" => [ "" ] },
          { "name" => [ "subfile", "type" ], "tag" => 255, "type" => [ "" ] },
          { "name" => [ "image", "width" ], "tag" => 256, "type" => [ "" ] },
          { "name" => [ "image", "length" ], "tag" => 257, "type" => [ "" ] },
          { "name" => [ "bits", "per", "sample" ], "tag" => 258, "type" => [ "" ] },
          { "name" => [ "compression" ], "tag" => 259, "type" => [ "" ] },
          { "name" => [ "photometric", "interpretation" ], "tag" => 262, "type" => [ "" ] },
          { "name" => [ "threshholding" ], "tag" => 263, "type" => [ "" ] },
          { "name" => [ "cell", "width" ], "tag" => 264, "type" => [ "" ] },
          { "name" => [ "cell", "length" ], "tag" => 265, "type" => [ "" ] },
          { "name" => [ "fill", "order" ], "tag" => 266, "type" => [ "" ] },
          { "name" => [ "document", "name" ], "tag" => 269, "type" => [ "" ] },
          { "name" => [ "image", "description" ], "tag" => 270, "type" => [ "" ] },
          { "name" => [ "make" ], "tag" => 271, "type" => [ "" ] },
          { "name" => [ "model" ], "tag" => 272, "type" => [ "" ] },
          { "name" => [ "strip", "offsets" ], "tag" => 273, "type" => [ "" ] },
          { "name" => [ "orientation" ], "tag" => 274, "type" => [ "" ] },
          { "name" => [ "samples", "per", "pixel" ], "tag" => 277, "type" => [ "" ] },
          { "name" => [ "rows", "per", "strip" ], "tag" => 278, "type" => [ "" ] },
          { "name" => [ "strip", "byte", "counts" ], "tag" => 279, "type" => [ "" ] },
          { "name" => [ "min", "sample", "value" ], "tag" => 280, "type" => [ "" ] },
          { "name" => [ "max", "sample", "value" ], "tag" => 281, "type" => [ "" ] },
          { "name" => [ "x", "resolution" ], "tag" => 282, "type" => [ "" ] },
          { "name" => [ "y", "resolution" ], "tag" => 283, "type" => [ "" ] },
          { "name" => [ "planar", "configuration" ], "tag" => 284, "type" => [ "" ] },
          { "name" => [ "page", "name" ], "tag" => 285, "type" => [ "" ] },
          { "name" => [ "x", "position" ], "tag" => 286, "type" => [ "" ] },
          { "name" => [ "y", "position" ], "tag" => 287, "type" => [ "" ] },
          { "name" => [ "free", "offsets" ], "tag" => 288, "type" => [ "" ] },
          { "name" => [ "free", "byte", "counts" ], "tag" => 289, "type" => [ "" ] },
          { "name" => [ "gray", "response", "unit" ], "tag" => 290, "type" => [ "" ] },
          { "name" => [ "gray", "response", "curve" ], "tag" => 291, "type" => [ "" ] },
          { "name" => [ "t4", "options" ], "tag" => 292, "type" => [ "" ] },
          { "name" => [ "t6", "options" ], "tag" => 293, "type" => [ "" ] },
          { "name" => [ "resolution", "unit" ], "tag" => 296, "type" => [ "" ] },
          { "name" => [ "page", "number" ], "tag" => 297, "type" => [ "" ] },
          { "name" => [ "transfer", "function" ], "tag" => 301, "type" => [ "" ] },
          { "name" => [ "software" ], "tag" => 305, "type" => [ "" ] },
          { "name" => [ "date", "time" ], "tag" => 306, "type" => [ "" ] },
          { "name" => [ "artist" ], "tag" => 315, "type" => [ "" ] },
          { "name" => [ "host", "computer" ], "tag" => 316, "type" => [ "" ] },
          { "name" => [ "predictor" ], "tag" => 317, "type" => [ "" ] },
          { "name" => [ "white", "point" ], "tag" => 318, "type" => [ "" ] },
          { "name" => [ "primary", "chromaticities" ], "tag" => 319, "type" => [ "" ] },
          { "name" => [ "color", "map" ], "tag" => 320, "type" => [ "" ] },
          { "name" => [ "halftone", "hints" ], "tag" => 321, "type" => [ "" ] },
          { "name" => [ "tile", "width" ], "tag" => 322, "type" => [ "" ] },
          { "name" => [ "tile", "length" ], "tag" => 323, "type" => [ "" ] }, 
          { "name" => [ "tile", "offsets" ], "tag" => 324, "type" => [ "" ] }, 
          { "name" => [ "tile", "byte", "counts" ], "tag" => 325, "type" => [ "" ] }, 
          { "name" => [ "ink", "set" ], "tag" => 332, "type" => [ "" ] }, 
          { "name" => [ "ink", "names" ], "tag" => 333, "type" => [ "" ] }, 
          { "name" => [ "number", "Of", "inks" ], "tag" => 334, "type" => [ "" ] }, 
          { "name" => [ "dot", "range" ], "tag" => 336, "type" => [ "" ] }, 
          { "name" => [ "target", "printer" ], "tag" => 337, "type" => [ "" ] }, 
          { "name" => [ "Extra", "samples" ], "tag" => 338, "type" => [ "" ] }, 
          { "name" => [ "sample", "format" ], "tag" => 339, "type" => [ "" ] }, 
          { "name" => [ "smin", "sample", "value" ], "tag" => 340, "type" => [ "" ] }, 
          { "name" => [ "smax", "sample", "value" ], "tag" => 341, "type" => [ "" ] }, 
          { "name" => [ "transfer", "range" ], "tag" => 342, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "proc" ], "tag" => 512, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "interchange", "format" ], "tag" => 513, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "interchange", "format", "length" ], "tag" => 514, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "restart", "interval" ], "tag" => 515, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "lossless", "predictors" ], "tag" => 517, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "point", "transforms" ], "tag" => 518, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "q", "tables" ], "tag" => 519, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "dc", "tables" ], "tag" => 520, "type" => [ "" ] }, 
          { "name" => [ "jpeg", "ac", "tables" ], "tag" => 521, "type" => [ "" ] }, 
          { "name" => [ "y", "cb", "cr", "coefficients" ], "tag" => 529, "type" => [ "" ] }, 
          { "name" => [ "y", "cb", "cr", "sub", "Sampling" ], "tag" => 530, "type" => [ "" ] }, 
          { "name" => [ "y", "cb", "cr", "positioning" ], "tag" => 531, "type" => [ "" ] }, 
          { "name" => [ "reference", "black", "white" ], "tag" => 532, "type" => [ "" ] }, 
          { "name" => [ "strip", "row", "counts" ], "tag" => 559, "type" => [ "" ] }, 
          { "name" => [ "xmp" ], "tag" => 700, "type" => [ "" ] },
          { "name" => [ "image", "rating" ], "tag" => 18246, "type" => [ "" ] }, 
          { "name" => [ "image", "rating", "percent" ], "tag" => 18249, "type" => [ "" ] }, 
          { "name" => [ "image", "id" ], "tag" => 32781, "type" => [ "" ] }, 
          { "name" => [ "wang", "annotation" ], "tag" => 32932, "type" => [ "" ] }, 
          { "name" => [ "cfa", "repeat", "pattern", "dim" ], "tag" => 33421, "type" => [ "" ] }, 
          { "name" => [ "cfa", "pattern" ], "tag" => 33422, "type" => [ "" ] }, 
          { "name" => [ "battery", "level" ], "tag" => 33423, "type" => [ "" ] }, 
          { "name" => [ "copyright" ], "tag" => 33432, "type" => [ "" ] }, 
          { "name" => [ "exposure", "time" ], "tag" => 33434, "type" => [ "" ] }, 
          { "name" => [ "f", "number" ], "tag" => 33437, "type" => [ "" ] }, 
          { "name" => [ "md", "file", "tag" ], "tag" => 33445, "type" => [ "" ] }, 
          { "name" => [ "md", "scale", "pixel" ], "tag" => 33446, "type" => [ "" ] }, 
          { "name" => [ "md", "color", "table" ], "tag" => 33447, "type" => [ "" ] }, 
          { "name" => [ "md", "lab", "name" ], "tag" => 33448, "type" => [ "" ] }, 
          { "name" => [ "md", "sample", "info" ], "tag" => 33449, "type" => [ "" ] }, 
          { "name" => [ "md", "prep", "date" ], "tag" => 33450, "type" => [ "" ] }, 
          { "name" => [ "md", "prep", "time" ], "tag" => 33451, "type" => [ "" ] }, 
          { "name" => [ "md", "file", "units" ], "tag" => 33452, "type" => [ "" ] }, 
          { "name" => [ "model", "pixel", "scale", "tag" ], "tag" => 33550, "type" => [ "" ] }, 
          { "name" => [ "iptcnaa" ], "tag" => 33723, "type" => [ "" ] }, 
          { "name" => [ "ingr", "packet", "data", "tag" ], "tag" => 33918, "type" => [ "" ] }, 
          { "name" => [ "ingr", "flag", "registers" ], "tag" => 33919, "type" => [ "" ] }, 
          { "name" => [ "iras", "b", "transformation", "matrix" ], "tag" => 33920, "type" => [ "" ] }, 
          { "name" => [ "model", "tiepoint", "tag" ], "tag" => 33922, "type" => [ "" ] }, 
          { "name" => [ "site" ], "tag" => 34016, "type" => [ "" ] }, 
          { "name" => [ "color", "sequence" ], "tag" => 34017, "type" => [ "" ] }, 
          { "name" => [ "it8", "header" ], "tag" => 34018, "type" => [ "" ] }, 
          { "name" => [ "raster", "padding" ], "tag" => 34019, "type" => [ "" ] }, 
          { "name" => [ "bits", "per", "run", "length" ], "tag" => 34020, "type" => [ "" ] }, 
          { "name" => [ "bits", "per", "extended", "run", "length" ], "tag" => 34021, "type" => [ "" ] }, 
          { "name" => [ "color", "table" ], "tag" => 34022, "type" => [ "" ] }, 
          { "name" => [ "image", "color", "indicator" ], "tag" => 34023, "type" => [ "" ] }, 
          { "name" => [ "background", "color", "indicator" ], "tag" => 34024, "type" => [ "" ] }, 
          { "name" => [ "image", "color", "value" ], "tag" => 34025, "type" => [ "" ] }, 
          { "name" => [ "background", "color", "value" ], "tag" => 34026, "type" => [ "" ] }, 
          { "name" => [ "pixel", "intensity", "range" ], "tag" => 34027, "type" => [ "" ] }, 
          { "name" => [ "transparency", "indicator" ], "tag" => 34028, "type" => [ "" ] }, 
          { "name" => [ "color", "characterization" ], "tag" => 34029, "type" => [ "" ] }, 
          { "name" => [ "hc", "usage" ], "tag" => 34030, "type" => [ "" ] }, 
          { "name" => [ "trap", "indicator" ], "tag" => 34031, "type" => [ "" ] }, 
          { "name" => [ "cmyk", "equivalent" ], "tag" => 34032, "type" => [ "" ] }, 
          { "name" => [ "reserved_34033" ], "tag" => 34033, "type" => [ "" ] }, 
          { "name" => [ "reserved_34034" ], "tag" => 34034, "type" => [ "" ] }, 
          { "name" => [ "reserved_34035" ], "tag" => 34035, "type" => [ "" ] }, 
          { "name" => [ "model", "transformation", "tag" ], "tag" => 34264, "type" => [ "" ] }, 
          { "name" => [ "photoshop" ], "tag" => 34377, "type" => [ "" ] }, 
          { "name" => [ "exif", "ifd" ], "tag" => 34665, "type" => [ "" ] }, 
          { "name" => [ "inter", "color", "profile" ], "tag" => 34675, "type" => [ "" ] }, 
          { "name" => [ "image", "layer" ], "tag" => 34732, "type" => [ "" ] }, 
          { "name" => [ "geo", "key", "directory", "tag" ], "tag" => 34735, "type" => [ "" ] }, 
          { "name" => [ "geo", "double", "params", "tag" ], "tag" => 34736, "type" => [ "" ] }, 
          { "name" => [ "geo", "ascii", "params", "tag" ], "tag" => 34737, "type" => [ "" ] }, 
          { "name" => [ "exposure", "program" ], "tag" => 34850, "type" => [ "" ] }, 
          { "name" => [ "spectral", "sensitivity" ], "tag" => 34852, "type" => [ "" ] }, 
          { "name" => [ "gps", "info" ], "tag" => 34853, "type" => [ "" ] }, 
          { "name" => [ "iso", "speed", "ratings" ], "tag" => 34855, "type" => [ "" ] }, 
          { "name" => [ "oecf" ], "tag" => 34856, "type" => [ "" ] }, 
          { "name" => [ "interlace" ], "tag" => 34857, "type" => [ "" ] }, 
          { "name" => [ "time", "zone", "offset" ], "tag" => 34858, "type" => [ "" ] }, 
          { "name" => [ "self", "time", "mode" ], "tag" => 34859, "type" => [ "" ] }, 
          { "name" => [ "sensitivity", "type" ], "tag" => 34864, "type" => [ "" ] }, 
          { "name" => [ "standard", "output", "sensitivity" ], "tag" => 34865, "type" => [ "" ] }, 
          { "name" => [ "recommended", "exposure", "index" ], "tag" => 34866, "type" => [ "" ] }, 
          { "name" => [ "iso", "speed" ], "tag" => 34867, "type" => [ "" ] }, 
          { "name" => [ "iso", "speed", "latitude", "yyy" ], "tag" => 34868, "type" => [ "" ] }, 
          { "name" => [ "iso", "Speed", "latitude", "zzz" ], "tag" => 34869, "type" => [ "" ] }, 
          { "name" => [ "hyla", "fax", "fax", "recv", "params" ], "tag" => 34908, "type" => [ "" ] }, 
          { "name" => [ "hyla", "fax", "fax", "sub", "address" ], "tag" => 34909, "type" => [ "" ] }, 
          { "name" => [ "hyla", "fax", "fax", "recv", "time" ], "tag" => 34910, "type" => [ "" ] }, 
          { "name" => [ "exif", "version" ], "tag" => 36864, "type" => [ "" ] }, 
          { "name" => [ "date", "time", "original" ], "tag" => 36867, "type" => [ "" ] }, 
          { "name" => [ "date", "time", "digitized" ], "tag" => 36868, "type" => [ "" ] }, 
          { "name" => [ "components", "configuration" ], "tag" => 37121, "type" => [ "" ] }, 
          { "name" => [ "compressed", "bits", "per", "pixel" ], "tag" => 37122, "type" => [ "" ] }, 
          { "name" => [ "shutter", "speed", "value" ], "tag" => 37377, "type" => [ "" ] }, 
          { "name" => [ "aperture", "value" ], "tag" => 37378, "type" => [ "" ] }, 
          { "name" => [ "frightness", "value" ], "tag" => 37379, "type" => [ "" ] }, 
          { "name" => [ "exposure", "bias", "value" ], "tag" => 37380, "type" => [ "" ] }, 
          { "name" => [ "max", "aperture", "value" ], "tag" => 37381, "type" => [ "" ] }, 
          { "name" => [ "subject", "distance" ], "tag" => 37382, "type" => [ "" ] }, 
          { "name" => [ "metering", "mode" ], "tag" => 37383, "type" => [ "" ] }, 
          { "name" => [ "light", "source" ], "tag" => 37384, "type" => [ "" ] }, 
          { "name" => [ "flash" ], "tag" => 37385, "type" => [ "" ] }, 
          { "name" => [ "focal", "length" ], "tag" => 37386, "type" => [ "" ] }, 
          { "name" => [ "flash", "energy" ], "tag" => 37387, "type" => [ "" ] }, 
          { "name" => [ "spatial", "frequency", "response" ], "tag" => 37388, "type" => [ "" ] }, 
          { "name" => [ "noise" ], "tag" => 37389, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "x", "resolution" ], "tag" => 37390, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "y", "resolution" ], "tag" => 37391, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "resolution", "unit" ], "tag" => 37392, "type" => [ "" ] }, 
          { "name" => [ "image", "number" ], "tag" => 37393, "type" => [ "" ] }, 
          { "name" => [ "security", "classification" ], "tag" => 37394, "type" => [ "" ] }, 
          { "name" => [ "image", "history" ], "tag" => 37395, "type" => [ "" ] }, 
          { "name" => [ "subject", "location" ], "tag" => 37396, "type" => [ "" ] }, 
          { "name" => [ "exposure", "index" ], "tag" => 37397, "type" => [ "" ] }, 
          { "name" => [ "tiffep", "standard", "id" ], "tag" => 37398, "type" => [ "" ] }, 
          { "name" => [ "sensing", "method" ], "tag" => 37399, "type" => [ "" ] }, 
          { "name" => [ "maker", "note" ], "tag" => 37500, "type" => [ "" ] }, 
          { "name" => [ "user", "comment" ], "tag" => 37510, "type" => [ "" ] }, 
          { "name" => [ "subsec", "time" ], "tag" => 37520, "type" => [ "" ] }, 
          { "name" => [ "subsec", "time", "original" ], "tag" => 37521, "type" => [ "" ] }, 
          { "name" => [ "subsec", "time", "digitized" ], "tag" => 37522, "type" => [ "" ] }, 
          { "name" => [ "Image", "source", "data" ], "tag" => 37724, "type" => [ "" ] }, 
          { "name" => [ "xp", "title" ], "tag" => 40091, "type" => [ "" ] }, 
          { "name" => [ "xp", "comment" ], "tag" => 40092, "type" => [ "" ] }, 
          { "name" => [ "xp", "author" ], "tag" => 40093, "type" => [ "" ] }, 
          { "name" => [ "xp", "keywords" ], "tag" => 40094, "type" => [ "" ] }, 
          { "name" => [ "xp", "subject" ], "tag" => 40095, "type" => [ "" ] }, 
          { "name" => [ "flashpix", "version" ], "tag" => 40960, "type" => [ "" ] }, 
          { "name" => [ "color", "space" ], "tag" => 40961, "type" => [ "" ] }, 
          { "name" => [ "pixel", "x", "dimension" ], "tag" => 40962, "type" => [ "" ] }, 
          { "name" => [ "pixel", "y", "dimension" ], "tag" => 40963, "type" => [ "" ] }, 
          { "name" => [ "related", "sound", "file" ], "tag" => 40964, "type" => [ "" ] }, 
          { "name" => [ "interoperability", "ifd" ], "tag" => 40965, "type" => [ "" ] }, 
          { "name" => [ "flash", "energy" ], "tag" => 41483, "type" => [ "" ] }, 
          { "name" => [ "spatial", "frequency", "response" ], "tag" => 41484, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "x", "resolution" ], "tag" => 41486, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "y", "resolution" ], "tag" => 41487, "type" => [ "" ] }, 
          { "name" => [ "focal", "plane", "resolution", "unit" ], "tag" => 41488, "type" => [ "" ] }, 
          { "name" => [ "subject", "location" ], "tag" => 41492, "type" => [ "" ] }, 
          { "name" => [ "exposure", "index" ], "tag" => 41493, "type" => [ "" ] }, 
          { "name" => [ "sensing", "method" ], "tag" => 41495, "type" => [ "" ] }, 
          { "name" => [ "file", "source" ], "tag" => 41728, "type" => [ "" ] }, 
          { "name" => [ "scene", "type" ], "tag" => 41729, "type" => [ "" ] }, 
          { "name" => [ "cfa", "pattern" ], "tag" => 41730, "type" => [ "" ] }, 
          { "name" => [ "custom", "rendered" ], "tag" => 41985, "type" => [ "" ] }, 
          { "name" => [ "exposure", "mode" ], "tag" => 41986, "type" => [ "" ] }, 
          { "name" => [ "white", "balance" ], "tag" => 41987, "type" => [ "" ] }, 
          { "name" => [ "digital", "zoom", "ratio" ], "tag" => 41988, "type" => [ "" ] }, 
          { "name" => [ "focal", "length", "in", "35mm", "film" ], "tag" => 41989, "type" => [ "" ] }, 
          { "name" => [ "scene", "capture", "type" ], "tag" => 41990, "type" => [ "" ] }, 
          { "name" => [ "gain", "control" ], "tag" => 41991, "type" => [ "" ] }, 
          { "name" => [ "contrast" ], "tag" => 41992, "type" => [ "" ] }, 
          { "name" => [ "saturation" ], "tag" => 41993, "type" => [ "" ] }, 
          { "name" => [ "sharpness" ], "tag" => 41994, "type" => [ "" ] }, 
          { "name" => [ "device", "setting", "description" ], "tag" => 41995, "type" => [ "" ] }, 
          { "name" => [ "subject", "distance", "range" ], "tag" => 41996, "type" => [ "" ] }, 
          { "name" => [ "image", "unique", "id" ], "tag" => 42016, "type" => [ "" ] }, 
          { "name" => [ "camera", "owner", "name" ], "tag" => 42032, "type" => [ "" ] }, 
          { "name" => [ "body", "serial", "number" ], "tag" => 42033, "type" => [ "" ] }, 
          { "name" => [ "lens", "specification" ], "tag" => 42034, "type" => [ "" ] }, 
          { "name" => [ "lens", "make" ], "tag" => 42035, "type" => [ "" ] }, 
          { "name" => [ "lens", "model" ], "tag" => 42036, "type" => [ "" ] }, 
          { "name" => [ "lens", "serial", "number" ], "tag" => 42037, "type" => [ "" ] }, 
          { "name" => [ "gdalmetadata" ], "tag" => 42112, "type" => [ "" ] }, 
          { "name" => [ "gdalnodata" ], "tag" => 42113, "type" => [ "" ] }, 
          { "name" => [ "pixel", "format" ], "tag" => 48129, "type" => [ "" ] }, 
          { "name" => [ "transformation" ], "tag" => 48130, "type" => [ "" ] }, 
          { "name" => [ "uncompressed" ], "tag" => 48131, "type" => [ "" ] }, 
          { "name" => [ "image", "type" ], "tag" => 48132, "type" => [ "" ] }, 
          { "name" => [ "image", "width" ], "tag" => 48256, "type" => [ "" ] }, 
          { "name" => [ "image", "height" ], "tag" => 48257, "type" => [ "" ] }, 
          { "name" => [ "width", "resolution" ], "tag" => 48258, "type" => [ "" ] },
          { "name" => [ "height", "resolution" ], "tag" => 48259, "type" => [ "" ] }, 
          { "name" => [ "image", "offset" ], "tag" => 48320, "type" => [ "" ] }, 
          { "name" => [ "image", "byte", "count" ], "tag" => 48321, "type" => [ "" ] }, 
          { "name" => [ "alpha", "offset" ], "tag" => 48322, "type" => [ "" ] }, 
          { "name" => [ "alpha", "byte", "count" ], "tag" => 48323, "type" => [ "" ] }, 
          { "name" => [ "image", "bata", "discard" ], "tag" => 48324, "type" => [ "" ] }, 
          { "name" => [ "alpha", "data", "discard" ], "tag" => 48325, "type" => [ "" ] }, 
          { "name" => [ "oce", "scanjob", "description" ], "tag" => 50215, "type" => [ "" ] }, 
          { "name" => [ "oce", "application", "selector" ], "tag" => 50216, "type" => [ "" ] }, 
          { "name" => [ "oce", "identification", "number" ], "tag" => 50217, "type" => [ "" ] }, 
          { "name" => [ "oce", "image", "logic", "characteristics" ], "tag" => 50218, "type" => [ "" ] }, 
          { "name" => [ "print", "image", "matching" ], "tag" => 50341, "type" => [ "" ] }, 
          { "name" => [ "dng", "version" ], "tag" => 50706, "type" => [ "" ] }, 
          { "name" => [ "dng", "backward", "version" ], "tag" => 50707, "type" => [ "" ] }, 
          { "name" => [ "unique", "camera", "model" ], "tag" => 50708, "type" => [ "" ] }, 
          { "name" => [ "localized", "camera", "model" ], "tag" => 50709, "type" => [ "" ] }, 
          { "name" => [ "cfa", "plane", "Color" ], "tag" => 50710, "type" => [ "" ] }, 
          { "name" => [ "cfa", "layout" ], "tag" => 50711, "type" => [ "" ] }, 
          { "name" => [ "linearization", "table" ], "tag" => 50712, "type" => [ "" ] }, 
          { "name" => [ "black", "level", "repeat", "dim" ], "tag" => 50713, "type" => [ "" ] }, 
          { "name" => [ "black", "level" ], "tag" => 50714, "type" => [ "" ] }, 
          { "name" => [ "black", "level", "delta", "h" ], "tag" => 50715, "type" => [ "" ] }, 
          { "name" => [ "black", "level", "delta", "v" ], "tag" => 50716, "type" => [ "" ] },
          { "name" => [ "white", "level" ], "tag" => 50717, "type" => [ "" ] }, 
          { "name" => [ "default", "scale" ], "tag" => 50718, "type" => [ "" ] }, 
          { "name" => [ "default", "crop", "origin" ], "tag" => 50719, "type" => [ "" ] }, 
          { "name" => [ "default", "crop", "size" ], "tag" => 50720, "type" => [ "" ] }, 
          { "name" => [ "color", "matrix", "1" ], "tag" => 50721, "type" => [ "" ] }, 
          { "name" => [ "color", "matrix", "2" ], "tag" => 50722, "type" => [ "" ] }, 
          { "name" => [ "camera", "calibration", "1" ], "tag" => 50723, "type" => [ "" ] }, 
          { "name" => [ "camera", "calibration", "2" ], "tag" => 50724, "type" => [ "" ] }, 
          { "name" => [ "reduction", "matrix", "1" ], "tag" => 50725, "type" => [ "" ] }, 
          { "name" => [ "reduction", "matrix", "2" ], "tag" => 50726, "type" => [ "" ] }, 
          { "name" => [ "analog", "balance" ], "tag" => 50727, "type" => [ "" ] }, 
          { "name" => [ "as", "shot", "neutral" ], "tag" => 50728, "type" => [ "" ] }, 
          { "name" => [ "as", "shot", "white", "xy" ], "tag" => 50729, "type" => [ "" ] }, 
          { "name" => [ "baseline", "exposure" ], "tag" => 50730, "type" => [ "" ] }, 
          { "name" => [ "baseline", "noise" ], "tag" => 50731, "type" => [ "" ] }, 
          { "name" => [ "baseline", "sharpness" ], "tag" => 50732, "type" => [ "" ] }, 
          { "name" => [ "bayer", "green", "split" ], "tag" => 50733, "type" => [ "" ] }, 
          { "name" => [ "linear", "response", "limit" ], "tag" => 50734, "type" => [ "" ] }, 
          { "name" => [ "camera", "serial", "number" ], "tag" => 50735, "type" => [ "" ] }, 
          { "name" => [ "lens", "info" ], "tag" => 50736, "type" => [ "" ] }, 
          { "name" => [ "chroma", "blur", "radius" ], "tag" => 50737, "type" => [ "" ] }, 
          { "name" => [ "anti", "alias", "strength" ], "tag" => 50738, "type" => [ "" ] }, 
          { "name" => [ "shadow", "scale" ], "tag" => 50739, "type" => [ "" ] }, 
          { "name" => [ "dng", "private", "data" ], "tag" => 50740, "type" => [ "" ] }, 
          { "name" => [ "maker", "note", "safety" ], "tag" => 50741, "type" => [ "" ] }, 
          { "name" => [ "calibration", "illuminant", "1" ], "tag" => 50778, "type" => [ "" ] }, 
          { "name" => [ "calibration", "illuminant", "2" ], "tag" => 50779, "type" => [ "" ] }, 
          { "name" => [ "best", "quality", "scale" ], "tag" => 50780, "type" => [ "" ] }, 
          { "name" => [ "raw", "data", "unique", "id" ], "tag" => 50781, "type" => [ "" ] }, 
          { "name" => [ "alias", "layer", "metadata" ], "tag" => 50784, "type" => [ "" ] }, 
          { "name" => [ "original", "raw", "file", "data" ], "tag" => 50828, "type" => [ "" ] }, 
          { "name" => [ "active", "area" ], "tag" => 50829, "type" => [ "" ] }, 
          { "name" => [ "masked", "areas" ], "tag" => 50830, "type" => [ "" ] }, 
          { "name" => [ "as", "shot", "icc", "profile" ], "tag" => 50831, "type" => [ "" ] }, 
          { "name" => [ "as", "shot", "pre", "profile", "matrix" ], "tag" => 50832, "type" => [ "" ] }, 
          { "name" => [ "current", "icc", "profile" ], "tag" => 50833, "type" => [ "" ] }, 
          { "name" => [ "current", "pre", "profile", "matrix" ], "tag" => 50834, "type" => [ "" ] }, 
          { "name" => [ "colorimetric", "reference" ], "tag" => 50879, "type" => [ "" ] }, 
          { "name" => [ "camera", "calibration", "signature" ], "tag" => 50931, "type" => [ "" ] }, 
          { "name" => [ "profile", "calibration", "signature" ], "tag" => 50932, "type" => [ "" ] }, 
          { "name" => [ "extra", "camera", "profiles" ], "tag" => 50933, "type" => [ "" ] }, 
          { "name" => [ "as", "shot", "profile", "name" ], "tag" => 50934, "type" => [ "" ] }, 
          { "name" => [ "noise", "reduction", "applied" ], "tag" => 50935, "type" => [ "" ] }, 
          { "name" => [ "profile", "name" ], "tag" => 50936, "type" => [ "" ] }, 
          { "name" => [ "profile", "hue", "sat", "map", "dims" ], "tag" => 50937, "type" => [ "" ] }, 
          { "name" => [ "profile", "hue", "sat", "map", "data", "1" ], "tag" => 50938, "type" => [ "" ] }, 
          { "name" => [ "profile", "hue", "sat", "map", "data", "2" ], "tag" => 50939, "type" => [ "" ] }, 
          { "name" => [ "profile", "tone", "curve" ], "tag" => 50940, "type" => [ "" ] }, 
          { "name" => [ "profile", "embed", "policy" ], "tag" => 50941, "type" => [ "" ] }, 
          { "name" => [ "profile", "copyright" ], "tag" => 50942, "type" => [ "" ] }, 
          { "name" => [ "forward", "matrix", "1" ], "tag" => 50964, "type" => [ "" ] }, 
          { "name" => [ "forward", "matrix", "2" ], "tag" => 50965, "type" => [ "" ] }, 
          { "name" => [ "preview", "application", "name" ], "tag" => 50966, "type" => [ "" ] }, 
          { "name" => [ "preview", "application", "version" ], "tag" => 50967, "type" => [ "" ] }, 
          { "name" => [ "preview", "settings", "name" ], "tag" => 50968, "type" => [ "" ] }, 
          { "name" => [ "preview", "settings", "digest" ], "tag" => 50969, "type" => [ "" ] }, 
          { "name" => [ "preview", "color", "space" ], "tag" => 50970, "type" => [ "" ] }, 
          { "name" => [ "preview", "date", "time" ], "tag" => 50971, "type" => [ "" ] }, 
          { "name" => [ "raw", "image", "digest" ], "tag" => 50972, "type" => [ "" ] }, 
          { "name" => [ "original", "raw", "file", "digest" ], "tag" => 50973, "type" => [ "" ] }, 
          { "name" => [ "sub", "tile", "block", "size" ], "tag" => 50974, "type" => [ "" ] }, 
          { "name" => [ "row", "interleave", "factor" ], "tag" => 50975, "type" => [ "" ] }, 
          { "name" => [ "profile", "look", "table", "dims" ], "tag" => 50981, "type" => [ "" ] }, 
          { "name" => [ "profile", "look", "table", "data" ], "tag" => 50982, "type" => [ "" ] }, 
          { "name" => [ "opcode", "list", "1" ], "tag" => 51008, "type" => [ "" ] }, 
          { "name" => [ "opcode", "list", "2" ], "tag" => 51009, "type" => [ "" ] }, 
          { "name" => [ "opcode", "list", "3" ], "tag" => 51022, "type" => [ "" ] }, 
          { "name" => [ "noise", "profile" ], "tag" => 51041, "type" => [ "" ] }, 
          { "name" => [ "original", "default", "final", "size" ], "tag" => 51089, "type" => [ "" ] }, 
          { "name" => [ "original", "best", "quality", "final", "size" ], "tag" => 51090, "type" => [ "" ] }, 
          { "name" => [ "original", "default", "crop", "size" ], "tag" => 51091, "type" => [ "" ] }, 
          { "name" => [ "profile", "hue", "sat", "map", "encoding" ], "tag" => 51107, "type" => [ "" ] }, 
          { "name" => [ "profile", "look", "table", "encoding" ], "tag" => 51108, "type" => [ "" ] }, 
          { "name" => [ "baseline", "exposure", "offset" ], "tag" => 51109, "type" => [ "" ] }, 
          { "name" => [ "default", "black", "render" ], "tag" => 51110, "type" => [ "" ] }, 
          { "name" => [ "new", "raw", "image", "digest" ], "tag" => 51111, "type" => [ "" ] }, 
          { "name" => [ "raw", "to", "preview", "gain" ], "tag" => 51112, "type" => [ "" ] }, 
          { "name" => [ "default", "user", "crop" ], "tag" => 51125, "type" => [ "" ] }
        ]
      %}
      {% for description in descriptions %}
        {% suffix = "" %}
        {% for name in description["name"] %}
          {% suffix = suffix + "_#{ name.id }" %}
        {% end %}
        private def load_value{{suffix.id}}(dirEntry : DirectoryEntry)
          # TODO : raise if the type is wrong
          # dirEntry.type
          puts dirEntry.count
          if dirEntry.count < 2
            v = dirEntry.offset
            puts self.value_section_to_data dirEntry, String.new((pointerof(v)).as Pointer(UInt8), 4)            
          else
            nbrByte = dirEntry.count * self.type_sizeof dirEntry.type
            puts nbrByte
            @file.not_nil!.pos = dirEntry.offset
            puts self.value_section_to_data dirEntry, @file.not_nil!.gets(nbrByte).not_nil!
          end
        end
      {% end %}

      private def tag_call_to_function(dirEntry : DirectoryEntry)
        case dirEntry.tag
        {% for description in descriptions %}
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
        {% for description in descriptions %}
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

    ###########################################################################
    # It a Huge Messy & code write as shit
    ###########################################################################

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

    ###################################################################################################################
    # Loader Value form Tag
    ###################################################################################################################

    private def load_tile_offsets
    end

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
  end
end

image = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"

puts "end"
