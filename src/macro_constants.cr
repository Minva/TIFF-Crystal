module Tiff
  INTEL_BYTE_ORDER = Bytes.new "II".to_unsafe.as Pointer(UInt8), 2
  MOTOROLA_BYTE_ORDER = Bytes.new "MM".to_unsafe.as Pointer(UInt8), 2

  DESCRIPTIONS = [
    {
      "name" => [ "new", "subfile", "type" ],
      "tag" => 254,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => 0
    },
    {
      "name" => [ "subfile", "type" ],
      "tag" => 255,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "image", "width" ],
      "tag" => 256,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "image", "length" ],
      "tag" => 257,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "bits", "per", "sample" ],
      "tag" => 258,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => 1
    },
    {
      "name" => [ "compression" ],
      "tag" => 259,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # No Compression
    },
    {
      "name" => [ "photometric", "interpretation" ],
      "tag" => 262,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "threshholding" ],
      "tag" => 263,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # No Dithering
    },
    {
      "name" => [ "cell", "width" ],
      "tag" => 264,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "cell", "length" ],
      "tag" => 265,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "fill", "order" ],
      "tag" => 266,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # Lower column values in higher order bits
    },
    {
      "name" => [ "document", "name" ],
      "tag" => 269,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "image", "description" ],
      "tag" => 270,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "make" ],
      "tag" => 271,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "model" ],
      "tag" => 272,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "strip", "offsets" ],
      "tag" => 273,
      "type" => [ "SHORT", "LONG" ],
      # N = StripsPerImage for PlanarConfiguration equal to 1;
      # N = SamplesPerPixel * StripsPerImage for PlanarConfiguration equal to 2
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "orientation" ],
      "tag" => 274,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1
    },
    {
      "name" => [ "samples", "per", "pixel" ],
      "tag" => 277,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1
    },
    {
      "name" => [ "rows", "per", "strip" ],
      "tag" => 278,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => 4294967295 # 2**32 - 1
    },
    {
      "name" => [ "strip", "byte", "counts" ],
      "tag" => 279,
      "type" => [ "SHORT", "LONG" ],
      # N = StripsPerImage for PlanarConfiguration equal to 1;
      # N = SamplesPerPixel * StripsPerImage for PlanarConfiguration equal to 2
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "min", "sample", "value" ],
      "tag" => 280,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => 0
    },
    {
      "name" => [ "max", "sample", "value" ],
      "tag" => 281,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      # TODO : default do be defined by a Proc
      "default" => nil # 2**(BitsPerSample) - 1
    },
    {
      "name" => [ "x", "resolution" ],
      "tag" => 282,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "y", "resolution" ],
      "tag" => 283,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "planar", "configuration" ],
      "tag" => 284,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # Chunky
    },
    {
      "name" => [ "page", "name" ],
      "tag" => 285,
      "type" => [ "ASCII" ],
      "dount" => 'N',
      "default" => nil
    },
    {
      "name" => [ "x", "position" ],
      "tag" => 286,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "y", "position" ],
      "tag" => 287,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "free", "offsets" ],
      "tag" => 288,
      "type" => [ "LONG" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "free", "byte", "counts" ],
      "tag" => 289,
      "type" => [ "LONG" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "gray", "response", "unit" ],
      "tag" => 290,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 2 # hundredths of a unit
    },
    {
      "name" => [ "gray", "response", "curve" ],
      "tag" => 291,
      "type" => [ "SHORT" ],
      # TODO : default do be defined by a Proc
      "count" => nil, # 2**BitsPerSample
      "default" => nil
    },
    {
      "name" => [ "t4", "options" ],
      "tag" => 292,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => 0 # basic 1-dimensional coding
    },
    {
      "name" => [ "t6", "options" ],
      "tag" => 293,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => 0
    },
    {
      "name" => [ "resolution", "unit" ],
      "tag" => 296,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 2 # Inch
    },
    {
      "name" => [ "page", "number" ],
      "tag" => 297,
      "type" => [ "SHORT" ],
      "count" => 2,
      "default" => nil
    },
    # {
    #   "name" => [ "transfer", "function" ],
    #   "tag" => 301,
    #   "type" => [ "SHORT" ],
    #   "count" => (1 or 3) * (1 << BitsPerSample)
    #   "default" => A single table corresponding to the NTSC standard gamma value of 2.2.
    # },
    {
      "name" => [ "software" ],
      "tag" => 305,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "date", "time" ],
      "tag" => 306,
      "type" => [ "ASCII" ],
      "count" => 20, # The format is: "YYYY:MM:DD HH:MM:SS"
      "default" => nil
    },
    {
      "name" => [ "artist" ],
      "tag" => 315,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "host", "computer" ],
      "tag" => 316,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "predictor" ],
      "tag" => 317,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # No Prediction
    },
    {
      "name" => [ "white", "point" ],
      "tag" => 318,
      "type" => [ "RATIONAL" ],
      "count" => 2,
      "default" => nil
    },
    {
      "name" => [ "primary", "chromaticities" ],
      "tag" => 319,
      "type" => [ "RATIONAL" ],
      "count" => 6,
      "default" => nil
    },
    {
      "name" => [ "color", "map" ],
      "tag" => 320,
      "type" => [ "SHORT" ],
      # TODO : default do be defined by a Proc
      "count" => nil, # 3 * (2**BitsPerSample)
      "default" => nil
    },
    {
      "name" => [ "halftone", "hints" ],
      "tag" => 321,
      "type" => [ "SHORT" ],
      "count" => 2,
      "default" => nil
    },
    {
      "name" => [ "tile", "width" ],
      "tag" => 322,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "tile", "length" ],
      "tag" => 323,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "tile", "offsets" ],
      "tag" => 324,
      "type" => [ "LONG" ],
      # N = TilesPerImage for PlanarConfiguration = 1;
      # N = SamplesPerPixel * TilesPerImage for PlanarConfiguration = 2
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "tile", "byte", "counts" ],
      "tag" => 325,
      "type" => [ "SHORT", "LONG" ],
      # N = TilesPerImage for PlanarConfiguration = 1;
      # N = SamplesPerPixel * TilesPerImage for PlanarConfiguration = 2
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "bad", "fax", "lines" ],
      "tag" => 326,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "clean", "fax", "data" ],
      "tag" => 327,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "consecutive", "bad", "fax", "lines" ],
      "tag" => 328,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    # {
    #   "name" => [ "sub", "ifds" ],
    #   "tag" => 330,
    #   "type" => [ "LONG", "IFD" ],
    #   "count" => 'N', # Number of child IFDs
    #   "default" => nil
    # },
    {
      "name" => [ "ink", "set" ],
      "tag" => 332,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # CMYK
    },
    {
      "name" => [ "ink", "names" ],
      "tag" => 333,
      "type" => [ "ASCII" ],
      "count" => 'N', # N = total number of characters in all the ink name strings, including the NULs
      "default" => nil
    },
    {
      "name" => [ "number", "of", "inks" ],
      "tag" => 334,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 4
    },
    # {
    #   "name" => [ "dot", "range" ],
    #   "tag" => 336,
    #   "type" => [ "BYTE", "SHORT" ],
    #   "count" => 2, or 2*SamplesPerPixel
    #   "default" => [0,2**BitsPerSample-1]
    # },
    {
      "name" => [ "target", "printer" ],
      "tag" => 337,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "extra", "samples" ],
      "tag" => 338,
      "type" => [ "SHORT" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "sample", "format" ],
      "tag" => 339,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => 1 # unsigned integer data

    },
    # {
    #   "name" => [ "smin", "sample", "value" ],
    #   "tag" => 340,
    #   "type" => [ "BYTE", "SHORT", "LONG", "RATIONAL", "DOUBLE" ],
    #   "count" => 'N', # N = SamplesPerPixel
    #   "default" => The minimum of the data type
    # },
    # {
    #  "name" => [ "smax", "sample", "value" ],
    #  "tag" => 341,
    #  "type" => [ "BYTE", "SHORT", "LONG", "RATIONAL", "DOUBLE" ],
    #  "count" => N = SamplesPerPixel
    #  "default" => The maximum of the data type.
    # },
    {
      "name" => [ "transfer", "range" ],
      "tag" => 342,
      "type" => [ "SHORT" ],
      "count" => 6,
      "default" => nil
    },
    {
      "name" => [ "clip", "path" ],
      "tag" => 343,
      "type" => [ "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "x", "clip", "path", "units" ],
      "tag" => 344,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "y", "clip", "path", "units" ],
      "tag" => 345,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil # Equal to XClipPathUnits
    },
    {
      "name" => [ "indexed" ],
      "tag" => 346,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Not Indexed
    },
    {
      "name" => [ "jpeg", "tables" ],
      "tag" => 347,
      "type" => [ "UNDEFINED" ],
      "count" => 'N', # N = number of bytes in tables datastream
      "default" => nil
    },
    {
      "name" => [ "opi", "proxy" ],
      "tag" => 351,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0
    },
    # {
    #   "name" => [ "global", "parameters", "ifd" ],
    #   "tag" => 400,
    #   "type" => [ "LONG", "IFD" ],
    #   "count" => 1,
    #   "default" => nil
    # },
    {
      "name" => [ "profile", "type" ],
      "tag" => 401,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "fax", "profile" ],
      "tag" => 402,
      "type" => [ "BYTE" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "coding", "methods" ],
      "tag" => 403,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "version", "year" ],
      "tag" => 404,
      "type" => [ "BYTE" ],
      "count" => 4,
      "default" => nil
    },
    {
      "name" => [ "mode", "number" ],
      "tag" => 405,
      "type" => [ "BYTE" ],
      "count" => 1,
      "default" => nil
    },
    # {
    #   "name" => [ "decode" ],
    #   "tag" => 433,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => 2 * SamplesPerPixel (= 6, for ITULAB)
    #   "default" => See Description
    # },
    # {
    #   "name" => [ "default", "image", "color" ],
    #   "tag" => 434,
    #   "type" => [ "SHORT" ],
    #   "count" => SamplesPerPixel
    #   "default" => For the Foreground layer image, the default value is black.
    #                For other cases, including the Background layer image, the default value is white.
    # },
    # {
    #   "name" => [ "jpeg", "proc" ],
    #   "tag" => 512,
    #   "type" => [ "SHORT" ],
    #   "count" => 1,
    #   "default" => None according to specification, though we do recommend using 1 (baseline sequential) as a default in readers
    # },
    {
      "name" => [ "jpeg", "interchange", "format" ],
      "tag" => 513,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "jpeg", "interchange", "format", "length" ],
      "tag" => 514,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "jpeg", "restart", "interval" ],
      "tag" => 515,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "jpeg", "lossless", "predictors" ],
      "tag" => 517,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => nil
    },
    {
      "name" => [ "jpeg", "point", "transforms" ],
      "tag" => 518,
      "type" => [ "SHORT" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => nil
    },
    {
      "name" => [ "jpeg", "q", "tables" ],
      "tag" => 519,
      "type" => [ "LONG" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => nil
    },
    {
      "name" => [ "jpeg", "dc", "tables" ],
      "tag" => 520,
      "type" => [ "LONG" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => nil
    },
    {
      "name" => [ "jpeg", "ac", "tables" ],
      "tag" => 521,
      "type" => [ "LONG" ],
      "count" => 'N', # N = SamplesPerPixel
      "default" => nil
    },
    {
      "name" => [ "y", "cb", "cr", "coefficients" ],
      "tag" => 529,
      "type" => [ "RATIONAL" ],
      "count" => 3,
      "default" => [ ( 299 / 1000 ), ( 587 / 1000 ), ( 114 / 1000 ) ]
    },
    {
      "name" => [ "y", "cb", "cr", "sub", "Sampling" ],
      "tag" => 530,
      "type" => [ "SHORT" ],
      "count" => 2,
      "default" => [2, 2]
    },
    {
      "name" => [ "y", "cb", "cr", "positioning" ],
      "tag" => 531,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1 # Centered
    },
    {
      "name" => [ "reference", "black", "white" ],
      "tag" => 532,
      "type" => [ "RATIONAL" ],
      "count" => 6,
      "default" => nil
    },
    {
      "name" => [ "strip", "row", "counts" ],
      "tag" => 559,
      "type" => [ "LONG" ],
      "count" => 'N', # Number of strips
      "default" => nil
    },
    {
      "name" => [ "xmp" ],
      "tag" => 700,
      "type" => [ "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "image", "rating" ],
    #   "tag" => 18246,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "rating", "percent" ],
    #   "tag" => 18249,
    #   "type" => []
    # },
    {
      "name" => [ "image", "id" ],
      "tag" => 32781,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "wang", "annotation" ],
      "tag" => 32932,
      "type" => [ "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "cfa", "repeat", "pattern", "dim" ],
    #   "tag" => 33421,
    #   "type" => []
    # },
    # {
    #   "name" => [ "cfa", "pattern" ],
    #   "tag" => 33422,
    #   "type" => []
    # },
    # {
    #   "name" => [ "battery", "level" ],
    #   "tag" => 33423,
    #   "type" => []
    # },
    {
      "name" => [ "copyright" ],
      "tag" => 33432,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "exposure", "time" ],
      "tag" => 33434,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "f", "number" ],
      "tag" => 33437,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "md", "file", "tag" ],
      "tag" => 33445,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => 128 # Linear data format
    },
    {
      "name" => [ "md", "scale", "pixel" ],
      "tag" => 33446,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1
    },
    {
      "name" => [ "md", "color", "table" ],
      "tag" => 33447,
      "type" => [ "SHORT" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "md", "lab", "name" ],
      "tag" => 33448,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "md", "sample", "info" ],
      "tag" => 33449,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "md", "prep", "date" ],
      "tag" => 33450,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "md", "prep", "time" ],
      "tag" => 33451,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "md", "file", "units" ],
      "tag" => 33452,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "model", "pixel", "scale", "tag" ],
      "tag" => 33550,
      "type" => [ "DOUBLE" ],
      "count" => 3,
      "default" => nil
    },
    {
      "name" => [ "iptc", "naa" ],
      "tag" => 33723,
      "type" => [ "UNDEFINED", "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "ingr", "packet", "data", "tag" ],
      "tag" => 33918,
      "type" => [ "SHORT" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "ingr", "flag", "registers" ],
      "tag" => 33919,
      "type" => [ "LONG" ],
      "count" => 16,
      "default" => nil
    },

    {
      "name" => [ "iras", "b", "transformation", "matrix" ],
      "tag" => 33920,
      "type" => [ "DOUBLE" ],
      "count" => 17, # possibly 16, but unlikely
      "default" => nil
    },
    {
      "name" => [ "model", "tiepoint", "tag" ],
      "tag" => 33922,
      "type" => [ "DOUBLE" ],
      "count" => 'N', # N = 6*K, with K = number of tiepoints
      "default" => nil
    },
    # {
    #   "name" => [ "site" ],
    #   "tag" => 34016,
    #   "type" => []
    # },
    # {
    #   "name" => [ "color", "sequence" ],
    #   "tag" => 34017,
    #   "type" => []
    # },
    # {
    #   "name" => [ "it8", "header" ],
    #   "tag" => 34018,
    #   "type" => []
    # },
    # {
    #   "name" => [ "raster", "padding" ],
    #   "tag" => 34019,
    #   "type" => []
    # },
    # {
    #   "name" => [ "bits", "per", "run", "length" ],
    #   "tag" => 34020,
    #   "type" => []
    # },
    # {
    #   "name" => [ "bits", "per", "extended", "run", "length" ],
    #   "tag" => 34021,
    #   "type" => []
    # },
    # {
    #   "name" => [ "color", "table" ],
    #   "tag" => 34022,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "color", "indicator" ],
    #   "tag" => 34023,
    #   "type" => []
    # },
    # {
    #   "name" => [ "background", "color", "indicator" ],
    #   "tag" => 34024,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "color", "value" ],
    #   "tag" => 34025,
    #   "type" => []
    # },
    # {
    #   "name" => [ "background", "color", "value" ],
    #   "tag" => 34026,
    #   "type" => []
    # },
    # {
    #   "name" => [ "pixel", "intensity", "range" ],
    #   "tag" => 34027,
    #   "type" => []
    # },
    # {
    #   "name" => [ "transparency", "indicator" ],
    #   "tag" => 34028,
    #   "type" => []
    # },
    # {
    #   "name" => [ "color", "characterization" ],
    #   "tag" => 34029,
    #   "type" => []
    # },
    # {
    #   "name" => [ "hc", "usage" ],
    #   "tag" => 34030,
    #   "type" => []
    # },
    # {
    #   "name" => [ "trap", "indicator" ],
    #   "tag" => 34031,
    #   "type" => []
    # },
    # {
    #   "name" => [ "cmyk", "equivalent" ],
    #   "tag" => 34032,
    #   "type" => []
    # },
    # {
    #   "name" => [ "reserved" ],
    #   "tag" => 34033,
    #   "type" => []
    # },
    # {
    #   "name" => [ "reserved" ],
    #   "tag" => 34034,
    #   "type" => []
    # },
    # {
    #   "name" => [ "reserved" ],
    #   "tag" => 34035,
    #   "type" => []
    # },
    {
      "name" => [ "model", "transformation", "tag" ],
      "tag" => 34264,
      "type" => [ "DOUBLE" ],
      "count" => 16,
      "default" => nil
    },
    {
      "name" => [ "photoshop" ],
      "tag" => 34377,
      "type" => [ "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "exif", "ifd" ],
      "tag" => 34665,
      "type" => [ "LONG", "IFD" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "inter", "color", "profile" ],
      "tag" => 34675,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "image", "layer" ],
      "tag" => 34732,
      "type" => [ "SHORT", "LONG" ],
      "count" => 2,
      "default" => nil
    },
    {
      "name" => [ "geo", "key", "directory", "tag" ],
      "tag" => 34735,
      "type" => [ "SHORT" ],
      "count" => 'N', # N >= 4
      "default" => nil
    },
    {
      "name" => [ "geo", "double", "params", "tag" ],
      "tag" => 34736,
      "type" => [ "DOUBLE" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "geo", "ascii", "params", "tag" ],
      "tag" => 34737,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "exposure", "program" ],
      "tag" => 34850,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Not defined
    },
    {
      "name" => [ "spectral", "sensitivity" ],
      "tag" => 34852,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "gps", "info" ],
      "tag" => 34853,
      "type" => [ "LONG", "IFD" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "iso", "speed", "ratings" ],
      "tag" => 34855,
      "type" => [ "SHORT" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "oecf" ],
      "tag" => 34856,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "interlace" ],
    #   "tag" => 34857,
    #   "type" => []
    # },
    # {
    #   "name" => [ "time", "zone", "offset" ],
    #   "tag" => 34858,
    #   "type" => []
    # },
    # {
    #   "name" => [ "self", "time", "mode" ],
    #   "tag" => 34859,
    #   "type" => []
    # },
    # {
    #   "name" => [ "sensitivity", "type" ],
    #   "tag" => 34864,
    #   "type" => []
    # },
    # {
    #   "name" => [ "standard", "output", "sensitivity" ],
    #   "tag" => 34865,
    #   "type" => []
    # },
    # {
    #   "name" => [ "recommended", "exposure", "index" ],
    #   "tag" => 34866,
    #   "type" => []
    # },
    # {
    #   "name" => [ "iso", "speed" ],
    #   "tag" => 34867,
    #   "type" => []
    # },
    # {
    #   "name" => [ "iso", "speed", "latitude", "yyy" ],
    #   "tag" => 34868,
    #   "type" => []
    # },
    # {
    #   "name" => [ "iso", "Speed", "latitude", "zzz" ],
    #   "tag" => 34869,
    #   "type" => []
    # },
    {
      "name" => [ "hyla", "fax", "fax", "recv", "params" ],
      "tag" => 34908,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "hyla", "fax", "fax", "sub", "address" ],
      "tag" => 34909,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "hyla", "fax", "fax", "recv", "time" ],
      "tag" => 34910,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "exif", "version" ],
      "tag" => 36864,
      "type" => [ "UNDEFINED" ],
      "count" => 4,
      "default" => [ 48, 50, 50, 48 ]
    },
    {
      "name" => [ "date", "time", "original" ],
      "tag" => 36867,
      "type" => [ "ASCII" ],
      "count" => 20,
      "default" => nil
    },
    {
      "name" => [ "date", "time", "digitized" ],
      "tag" => 36868,
      "type" => [ "ASCII" ],
      "count" => 20,
      "default" => nil
    },
    {
      "name" => [ "components", "configuration" ],
      "tag" => 37121,
      "type" => [ "UNDEFINED" ],
      "count" => 4,
      "default" => [ 4, 5, 6, 0 ] # if RGB uncompressed; 1,2,3,0 otherwise
    },
    {
      "name" => [ "compressed", "bits", "per", "pixel" ],
      "tag" => 37122,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "shutter", "speed", "value" ],
      "tag" => 37377,
      "type" => [ "SRATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "aperture", "value" ],
      "tag" => 37378,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "frightness", "value" ],
      "tag" => 37379,
      "type" => [ "SRATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "exposure", "bias", "value" ],
      "tag" => 37380,
      "type" => [ "SRATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "max", "aperture", "value" ],
      "tag" => 37381,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "subject", "distance" ],
      "tag" => 37382,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "metering", "mode" ],
      "tag" => 37383,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Unknown
    },
    {
      "name" => [ "light", "source" ],
      "tag" => 37384,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Unknown
    },
    {
      "name" => [ "flash" ],
      "tag" => 37385,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "focal", "length" ],
      "tag" => 37386,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },



    # {
    #   "name" => [ "flash", "energy" ],
    #   "tag" => 37387,
    #   "type" => []
    # },
    # {
    #   "name" => [ "spatial", "frequency", "response" ],
    #   "tag" => 37388,
    #   "type" => []
    # },
    # {
    #   "name" => [ "noise" ],
    #   "tag" => 37389,
    #   "type" => []
    # },
    # {
    #   "name" => [ "focal", "plane", "x", "resolution" ],
    #   "tag" => 37390,
    #   "type" => []
    # },
    # {
    #   "name" => [ "focal", "plane", "y", "resolution" ],
    #   "tag" => 37391,
    #   "type" => []
    # },
    # {
    #   "name" => [ "focal", "plane", "resolution", "unit" ],
    #   "tag" => 37392,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "number" ],
    #   "tag" => 37393,
    #   "type" => []
    # },
    # {
    #   "name" => [ "security", "classification" ],
    #   "tag" => 37394,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "history" ],
    #   "tag" => 37395,
    #   "type" => []
    # },
    {
      "name" => [ "subject", "area" ],
      "tag" => 37396,
      "type" => [ "SHORT" ],
      "count" => [ 2, 3, 4 ],
      "default" => nil
    },
    # {
    #   "name" => [ "exposure", "index" ],
    #   "tag" => 37397,
    #   "type" => []
    # },
    # {
    #   "name" => [ "tiffep", "standard", "id" ],
    #   "tag" => 37398,
    #   "type" => []
    # },
    # {
    #   "name" => [ "sensing", "method" ],
    #   "tag" => 37399,
    #   "type" => []
    # },
    {
      "name" => [ "maker", "note" ],
      "tag" => 37500,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "user", "comment" ],
      "tag" => 37510,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "subsec", "time" ],
      "tag" => 37520,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "subsec", "time", "original" ],
      "tag" => 37521,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "subsec", "time", "digitized" ],
      "tag" => 37522,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "image", "source", "data" ],
      "tag" => 37724,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "xp", "title" ],
    #   "tag" => 40091,
    #   "type" => []
    # },
    # {
    #   "name" => [ "xp", "comment" ],
    #   "tag" => 40092,
    #   "type" => []
    # },
    # {
    #   "name" => [ "xp", "author" ],
    #   "tag" => 40093,
    #   "type" => []
    # },
    # {
    #   "name" => [ "xp", "keywords" ],
    #   "tag" => 40094,
    #   "type" => []
    # },
    # {
    #   "name" => [ "xp", "subject" ],
    #   "tag" => 40095,
    #   "type" => []
    # },
    {
      "name" => [ "flashpix", "version" ],
      "tag" => 40960,
      "type" => [ "UNDEFINED" ],
      "count" => 4,
      "default" => [ 48, 49, 48, 48 ]
    },
    {
      "name" => [ "color", "space" ],
      "tag" => 40961,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "pixel", "x", "dimension" ],
      "tag" => 40962,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "pixel", "y", "dimension" ],
      "tag" => 40963,
      "type" => [ "SHORT", "LONG" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "related", "sound", "file" ],
      "tag" => 40964,
      "type" => [ "ASCII" ],
      "count" => 13,
      "default" => nil
    },
    # {
    #   "name" => [ "interoperability", "ifd" ],
    #   "tag" => 40965,
    #   "type" => [ "LONG", "IFD" ],
    #   "count" => 1,
    #   "default" => nil
    # },
    {
      "name" => [ "flash", "energy" ],
      "tag" => 41483,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "spatial", "frequency", "response" ],
      "tag" => 41484,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "focal", "plane", "x", "resolution" ],
      "tag" => 41486,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "focal", "plane", "y", "resolution" ],
      "tag" => 41487,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "focal", "plane", "resolution", "unit" ],
      "tag" => 41488,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 2 # inch
    },
    {
      "name" => [ "subject", "location" ],
      "tag" => 41492,
      "type" => [ "SHORT" ],
      "count" => 2,
      "default" => nil
    },
    {
      "name" => [ "exposure", "index" ],
      "tag" => 41493,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "sensing", "method" ],
      "tag" => 41495,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "file", "source" ],
      "tag" => 41728,
      "type" => [ "UNDEFINED" ],
      "count" => 1,
      "default" => 3 # Digital Still Camera
    },
    {
      "name" => [ "scene", "type" ],
      "tag" => 41729,
      "type" => [ "UNDEFINED" ],
      "count" => 1,
      "default" => 1 # Directly photographed image
    },
    {
      "name" => [ "cfa", "pattern" ],
      "tag" => 41730,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "custom", "rendered" ],
      "tag" => 41985,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Normal process
    },
    {
      "name" => [ "exposure", "mode" ],
      "tag" => 41986,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "white", "balance" ],
      "tag" => 41987,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "digital", "zoom", "ratio" ],
      "tag" => 41988,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "focal", "length", "in", "35mm", "film" ],
      "tag" => 41989,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "scene", "capture", "type" ],
      "tag" => 41990,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Standard
    },
    {
      "name" => [ "gain", "control" ],
      "tag" => 41991,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "contrast" ],
      "tag" => 41992,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Normal
    },
    {
      "name" => [ "saturation" ],
      "tag" => 41993,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Normal
    },
    {
      "name" => [ "sharpness" ],
      "tag" => 41994,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # Normal
    },
    {
      "name" => [ "device", "setting", "description" ],
      "tag" => 41995,
      "type" => [ "UNDEFINED" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "subject", "distance", "range" ],
      "tag" => 41996,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "image", "unique", "id" ],
      "tag" => 42016,
      "type" => [ "ASCII" ],
      "count" => 33,
      "default" => nil
    },
    # {
    #   "name" => [ "camera", "owner", "name" ],
    #   "tag" => 42032,
    #   "type" => []
    # },
    # {
    #   "name" => [ "body", "serial", "number" ],
    #   "tag" => 42033,
    #   "type" => []
    # },
    # {
    #   "name" => [ "lens", "specification" ],
    #   "tag" => 42034,
    #   "type" => []
    # },
    # {
    #   "name" => [ "lens", "make" ],
    #   "tag" => 42035,
    #   "type" => []
    # },
    # {
    #   "name" => [ "lens", "model" ],
    #   "tag" => 42036,
    #   "type" => []
    # },
    # {
    #   "name" => [ "lens", "serial", "number" ],
    #   "tag" => 42037,
    #   "type" => []
    # },
    {
      "name" => [ "gdal", "metadata" ],
      "tag" => 42112,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "gdal", "nodata" ],
      "tag" => 42113,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "pixel", "format" ],
    #   "tag" => 48129,
    #   "type" => []
    # },
    # {
    #   "name" => [ "transformation" ],
    #   "tag" => 48130,
    #   "type" => []
    # },
    # {
    #   "name" => [ "uncompressed" ],
    #   "tag" => 48131,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "type" ],
    #   "tag" => 48132,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "width" ],
    #   "tag" => 48256,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "height" ],
    #   "tag" => 48257,
    #   "type" => []
    # },
    # {
    #   "name" => [ "width", "resolution" ],
    #   "tag" => 48258,
    #   "type" => []
    # },
    # {
    #   "name" => [ "height", "resolution" ],
    #   "tag" => 48259,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "offset" ],
    #   "tag" => 48320,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "byte", "count" ],
    #   "tag" => 48321,
    #   "type" => []
    # },
    # {
    #   "name" => [ "alpha", "offset" ],
    #   "tag" => 48322,
    #   "type" => []
    # },
    # {
    #   "name" => [ "alpha", "byte", "count" ],
    #   "tag" => 48323,
    #   "type" => []
    # },
    # {
    #   "name" => [ "image", "bata", "discard" ],
    #   "tag" => 48324,
    #   "type" => []
    # },
    # {
    #   "name" => [ "alpha", "data", "discard" ],
    #   "tag" => 48325,
    #   "type" => []
    # },
    {
      "name" => [ "oce", "scanjob", "description" ],
      "tag" => 50215,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "oce", "application", "selector" ],
      "tag" => 50216,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "oce", "identification", "number" ],
      "tag" => 50217,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "oce", "image", "logic", "characteristics" ],
      "tag" => 50218,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "print", "image", "matching" ],
    #   "tag" => 50341,
    #   "type" => []
    # },
    {
      "name" => [ "dng", "version" ],
      "tag" => 50706,
      "type" => [ "BYTE" ],
      "count" => 4,
      "default" => nil
    },
    # {
    #   "name" => [ "dng", "backward", "version" ],
    #   "tag" => 50707,
    #   "type" => [ "BYTE" ],
    #   "count" => 4,
    #   "default" => DNGVersion with the last two bytes set to zero.
    # },
    {
      "name" => [ "unique", "camera", "model" ],
      "tag" => 50708,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "localized", "camera", "model" ],
    #   "tag" => 50709,
    #   "type" => [ "BYTE", "ASCII" ],
    #   "count" => 'N',
    #   "default" => Same as UniqueCameraModel
    # },
    # {
    #   "name" => [ "cfa", "plane", "Color" ],
    #   "tag" => 50710,
    #   "type" => [ "BYTE" ],
    #   "count" => ColorPlanes
    #   "default" => 0, 1, 2 (= red, green, blue)
    # },
    {
      "name" => [ "cfa", "layout" ],
      "tag" => 50711,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 1
    },
    # {
    #   "name" => [ "linearization", "table" ],
    #   "tag" => 50712,
    #   "type" => [ "SHORT" ],
    #   "count" => 'N',
    #   "default" => Identity table (0, 1, 2, 3, etc.)
    # },
    {
      "name" => [ "black", "level", "repeat", "dim" ],
      "tag" => 50713,
      "type" => [ "SHORT" ],
      "count" => 2,
      "default" => [ 1, 1 ]
    },
    # {
    #   "name" => [ "black", "level" ],
    #   "tag" => 50714,
    #   "type" => [ "SHORT", "LONG", "RATIONAL" ],
    #   "count" => BlackLevelRepeatRows * BlackLevelRepeatCols * SamplesPerPixel
    #   "default" => 0
    # },
    # {
    #   "name" => [ "black", "level", "delta", "h" ],
    #   "tag" => 50715,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ImageWidth
    #   "default" => All zeros
    # },
    # {
    #   "name" => [ "black", "level", "delta", "v" ],
    #   "tag" => 50716,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ImageLength
    #   "default" => All zeros
    # },
    # {
    #   "name" => [ "white", "level" ],
    #   "tag" => 50717,
    #   "type" => [ "SHORT", "LONG" ],
    #   "count" => SamplesPerPixel
    #   "default" => (2 ** BitsPerSample) - 1
    # },
    {
      "name" => [ "default", "scale" ],
      "tag" => 50718,
      "type" => [ "RATIONAL" ],
      "count" => 2,
      "default" => [ 1.0, 1.0 ]
    },
    {
      "name" => [ "default", "crop", "origin" ],
      "tag" => 50719,
      "type" => [ "SHORT", "LONG", "RATIONAL" ],
      "count" => 2,
      "default" => [ 0, 0 ]
    },
    # {
    #   "name" => [ "default", "crop", "size" ],
    #   "tag" => 50720,
    #   "type" => [ "SHORT", "LONG", "RATIONAL" ],
    #   "count" => 2,
    #   "default" => ImageWidth, ImageLength
    # },
    # {
    #   "name" => [ "color", "matrix", "1" ],
    #   "tag" => 50721,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ColorPlanes * 3,
    #   "default" => nil
    # },
    # {
    #   "name" => [ "color", "matrix", "2" ],
    #   "tag" => 50722,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ColorPlanes * 3,
    #   "default" => nil
    # },
    # {
    #   "name" => [ "camera", "calibration", "1" ],
    #   "tag" => 50723,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ColorPlanes * ColorPlanes
    #   "default" => Identity matrix
    # },
    # {
    #   "name" => [ "camera", "calibration", "2" ],
    #   "tag" => 50724,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => ColorPlanes * ColorPlanes
    #   "default" => Identity matrix
    # },
    # {
    #   "name" => [ "reduction", "matrix", "1" ],
    #   "tag" => 50725,
    #   "type" => [ "SRATIONAL" ],
    #   # "count" => 3 * ColorPlanes
    #   "default" => nil
    # },
    # {
    #   "name" => [ "reduction", "matrix", "2" ],
    #   "tag" => 50726,
    #   "type" => [ "SRATIONAL" ],
    #   "count" => 3 * ColorPlanes
    #   "default" => nil
    # },
    # {
    #   "name" => [ "analog", "balance" ],
    #   "tag" => 50727,
    #   "type" => [ "RATIONAL" ],
    #   "count" => ColorPlanes
    #   "default"=> All 1.0
    # },
    # {
    #   "name" => [ "as", "shot", "neutral" ],
    #   "tag" => 50728,
    #   "type" => [ "SHORT", "RATIONAL" ],
    #   "count" => ColorPlanes
    #   "default" => nil
    # },
    {
      "name" => [ "as", "shot", "white", "xy" ],
      "tag" => 50729,
      "type" => [ "RATIONAL" ],
      "count" => 2,
      "default" => nil
    },
    {
      "name" => [ "baseline", "exposure" ],
      "tag" => 50730,
      "type" => [ "SRATIONAL" ],
      "count" => 1,
      "default" => 0.0
    },
    {
      "name" => [ "baseline", "noise" ],
      "tag" => 50731,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1.0
    },
    {
      "name" => [ "baseline", "sharpness" ],
      "tag" => 50732,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1.0
    },
    {
      "name" => [ "bayer", "green", "split" ],
      "tag" => 50733,
      "type" => [ "LONG" ],
      "count" => 1,
      "default" => 0
    },
    {
      "name" => [ "linear", "response", "limit" ],
      "tag" => 50734,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1.0
    },
    {
      "name" => [ "camera", "serial", "number" ],
      "tag" => 50735,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "lens", "info" ],
      "tag" => 50736,
      "type" => [ "RATIONAL" ],
      "count" => 4,
      "default" => nil
    },
    # {
    #   "name" => [ "chroma", "blur", "radius" ],
    #   "tag" => 50737,
    #   "type" => [ "RATIONAL" ],
    #   "count" => 1,
    #   "default" => reader preference
    # },
    {
      "name" => [ "anti", "alias", "strength" ],
      "tag" => 50738,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1.0
    },
    # {
    #   "name" => [ "shadow", "scale" ],
    #   "tag" => 50739,
    #   "type" => []
    # },
    {
      "name" => [ "dng", "private", "data" ],
      "tag" => 50740,
      "type" => [ "BYTE" ],
      "count" => 'N',
      "default" => nil
    },
    {
      "name" => [ "maker", "note", "safety" ],
      "tag" => 50741,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0
    },
    {
      "name" => [ "calibration", "illuminant", "1" ],
      "tag" => 50778,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => 0 # unknown
    },
    {
      "name" => [ "calibration", "illuminant", "2" ],
      "tag" => 50779,
      "type" => [ "SHORT" ],
      "count" => 1,
      "default" => nil
    },
    {
      "name" => [ "best", "quality", "scale" ],
      "tag" => 50780,
      "type" => [ "RATIONAL" ],
      "count" => 1,
      "default" => 1.0
    },
    # {
    #   "name" => [ "raw", "data", "unique", "id" ],
    #   "tag" => 50781,
    #   "type" => []
    # },
    {
      "name" => [ "alias", "layer", "metadata" ],
      "tag" => 50784,
      "type" => [ "ASCII" ],
      "count" => 'N',
      "default" => nil
    },
    # {
    #   "name" => [ "original", "raw", "file", "name" ],
    #   "tag" => 50827,
    #   "type" => []
    # },
    # {
    #   "name" => [ "original", "raw", "file", "data" ],
    #   "tag" => 50828,
    #   "type" => []
    # },
    # {
    #   "name" => [ "active", "area" ],
    #   "tag" => 50829,
    #   "type" => []
    # },
    # {
    #   "name" => [ "masked", "areas" ],
    #   "tag" => 50830,
    #   "type" => []
    # },
    # {
    #   "name" => [ "as", "shot", "icc", "profile" ],
    #   "tag" => 50831,
    #   "type" => []
    # },
    # {
    #   "name" => [ "as", "shot", "pre", "profile", "matrix" ],
    #   "tag" => 50832,
    #   "type" => []
    # },
    # {
    #   "name" => [ "current", "icc", "profile" ],
    #   "tag" => 50833,
    #   "type" => []
    # },
    # {
    #   "name" => [ "current", "pre", "profile", "matrix" ],
    #   "tag" => 50834,
    #   "type" => []
    # },
    # {
    #   "name" => [ "colorimetric", "reference" ],
    #   "tag" => 50879,
    #   "type" => []
    # },
    # {
    #   "name" => [ "camera", "calibration", "signature" ],
    #   "tag" => 50931,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "calibration", "signature" ],
    #   "tag" => 50932,
    #   "type" => []
    # },
    # {
    #   "name" => [ "extra", "camera", "profiles" ],
    #   "tag" => 50933,
    #   "type" => []
    # },
    # {
    #   "name" => [ "as", "shot", "profile", "name" ],
    #   "tag" => 50934,
    #   "type" => []
    # },
    # {
    #   "name" => [ "noise", "reduction", "applied" ],
    #   "tag" => 50935,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "name" ],
    #   "tag" => 50936,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "hue", "sat", "map", "dims" ],
    #   "tag" => 50937,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "hue", "sat", "map", "data", "1" ],
    #   "tag" => 50938,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "hue", "sat", "map", "data", "2" ],
    #   "tag" => 50939,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "tone", "curve" ],
    #   "tag" => 50940,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "embed", "policy" ],
    #   "tag" => 50941,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "copyright" ],
    #   "tag" => 50942,
    #   "type" => []
    # },
    # {
    #   "name" => [ "forward", "matrix", "1" ],
    #   "tag" => 50964,
    #   "type" => []
    # },
    # {
    #   "name" => [ "forward", "matrix", "2" ],
    #   "tag" => 50965,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "application", "name" ],
    #   "tag" => 50966,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "application", "version" ],
    #   "tag" => 50967,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "settings", "name" ],
    #   "tag" => 50968,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "settings", "digest" ],
    #   "tag" => 50969,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "color", "space" ],
    #   "tag" => 50970,
    #   "type" => []
    # },
    # {
    #   "name" => [ "preview", "date", "time" ],
    #   "tag" => 50971,
    #   "type" => []
    # },
    # {
    #   "name" => [ "raw", "image", "digest" ],
    #   "tag" => 50972,
    #   "type" => []
    # },
    # {
    #   "name" => [ "original", "raw", "file", "digest" ],
    #   "tag" => 50973,
    #   "type" => []
    # },
    # {
    #   "name" => [ "sub", "tile", "block", "size" ],
    #   "tag" => 50974,
    #   "type" => []
    # },
    # {
    #   "name" => [ "row", "interleave", "factor" ],
    #   "tag" => 50975,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "look", "table", "dims" ],
    #   "tag" => 50981,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "look", "table", "data" ],
    #   "tag" => 50982,
    #   "type" => []
    # },
    # {
    #   "name" => [ "opcode", "list", "1" ],
    #   "tag" => 51008,
    #   "type" => []
    # },
    # {
    #   "name" => [ "opcode", "list", "2" ],
    #   "tag" => 51009,
    #   "type" => []
    # },
    # {
    #   "name" => [ "opcode", "list", "3" ],
    #   "tag" => 51022,
    #   "type" => []
    # },
    # {
    #   "name" => [ "noise", "profile" ],
    #   "tag" => 51041,
    #   "type" => []
    # },
    # {
    #   "name" => [ "original", "default", "final", "size" ],
    #   "tag" => 51089,
    #   "type" => []
    # },
    # {
    #   "name" => [ "original", "best", "quality", "final", "size" ],
    #   "tag" => 51090,
    #   "type" => []
    # },
    # {
    #   "name" => [ "original", "default", "crop", "size" ],
    #   "tag" => 51091,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "hue", "sat", "map", "encoding" ],
    #   "tag" => 51107,
    #   "type" => []
    # },
    # {
    #   "name" => [ "profile", "look", "table", "encoding" ],
    #   "tag" => 51108,
    #   "type" => []
    # },
    # {
    #   "name" => [ "baseline", "exposure", "offset" ],
    #   "tag" => 51109,
    #   "type" => []
    # },
    # {
    #   "name" => [ "default", "black", "render" ],
    #   "tag" => 51110,
    #   "type" => []
    # },
    # {
    #   "name" => [ "new", "raw", "image", "digest" ],
    #   "tag" => 51111,
    #   "type" => []
    # },
    # {
    #   "name" => [ "raw", "to", "preview", "gain" ],
    #   "tag" => 51112,
    #   "type" => []
    # },
    # {
    #   "name" => [ "default", "user", "crop" ],
    #   "tag" => 51125,
    #   "type" => []
    # }
  ]

  {% begin %}
    {% for description in DESCRIPTIONS %}
      {% suffix = "" %}
      {% for name in description["name"] %}
        {% suffix = suffix + "_#{ name.upcase.id }" %}
      {% end %}
      TAG{{ suffix.id }} = {{ description["tag"] }}_u16
    {% end %}
  {% end %}

  TYPES = [
    [ 1, UInt8, "BYTE" ],
    [ 2, String, "ASCII" ],
    [ 3, UInt16, "SHORT" ],
    [ 4, UInt32, "LONG" ],
    [ 5, UInt64, "RATIONAL" ],
    [ 6, Int8, "SBYTE" ],
    [ 7, Bytes, "UNDEFINED" ],
    [ 8, Int16, "SSHORT" ],
    [ 9, Int32, "SLONG" ],
    [ 10, Int64, "SRATIONAL" ],
    [ 11, Float32, "FLOAT" ],
    [ 12, Float64, "DOUBLE" ]
  ]

  {% begin %}
    {% for type in TYPES %}  
      TYPE_{{ type[2].id }} = {{ type[0] }}_u16
    {% end %}
  {% end %}
end
