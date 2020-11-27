# TODO: Write documentation for `Crystal::Tiff`
module Tiff
  VERSION = "0.1.0"

  class Tiff
    @file : File | Nil = nil

    def initialize(path : String)
      @file = File.new path
      self.image_file_header
      self.image_file_directory
    end
  
    def initialize(uri : URI)
    end
  
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

    private def tag_to_s(value : UInt16)
      case value
      when 254 then return "NewSubfileType"
      when 255 then return "SubfileType"
      when 256 then return "ImageWidth"
      when 257 then return "ImageLength"
      when 258 then return "BitsPerSample"
      when 259 then return "Compression"
      when 262 then return "PhotometricInterpretation"
      when 263 then return "Threshholding"
      when 264 then return "CellWidth"
      when 265 then return "CellLength"
      when 266 then return "FillOrder"
      when 269 then return "DocumentName"
      when 270 then return "ImageDescription"
      when 271 then return "Make"
      when 272 then return "Model"
      when 273 then return "StripOffsets"
      when 274 then return "Orientation"
      when 277 then return "SamplesPerPixel"
      when 278 then return "RowsPerStrip"
      when 279 then return "StripByteCounts"
      when 280 then return "MinSampleValue"
      when 281 then return "MaxSampleValue"
      when 282 then return "XResolution"
      when 283 then return "YResolution"
      when 284 then return "PlanarConfiguration"
      when 285 then return "PageName"
      when 286 then return "XPosition"
      when 287 then return "YPosition"
      when 288 then return "FreeOffsets"
      when 289 then return "FreeByteCounts"
      when 290 then return "GrayResponseUnit"
      when 291 then return "GrayResponseCurve"
      when 292 then return "T4Options"
      when 293 then return "T6Options"
      when 296 then return "ResolutionUnit"
      when 297 then return "PageNumber"
      when 301 then return "TransferFunction"
      when 305 then return "Software"
      when 306 then return "DateTime"
      when 315 then return "Artist"
      when 316 then return "HostComputer"
      when 317 then return "Predictor"
      when 318 then return "WhitePoint"
      when 319 then return "PrimaryChromaticities"
      when 320 then return "ColorMap"
      when 321 then return "HalftoneHints"
      when 322 then return "TileWidth"
      when 323 then return "TileLength"
      when 324 then return "TileOffsets"
      when 325 then return "TileByteCounts"
      when 332 then return "InkSet"
      when 333 then return "InkNames"
      when 334 then return "NumberOfInks"
      when 336 then return "DotRange"
      when 337 then return "TargetPrinter"
      when 338 then return "ExtraSamples"
      when 339 then return "SampleFormat"
      when 340 then return "SMinSampleValue"
      when 341 then return "SMaxSampleValue"
      when 342 then return "TransferRange"
      when 512 then return "JPEGProc"
      when 513 then return "JPEGInterchangeFormat"
      when 514 then return "JPEGInterchangeFormatLength"
      when 515 then return "JPEGRestartInterval"
      when 517 then return "JPEGLosslessPredictors"
      when 518 then return "JPEGPointTransforms"
      when 519 then return "JPEGQTables"
      when 520 then return "JPEGDCTables"
      when 521 then return "JPEGACTables"
      when 529 then return "YCbCrCoefficients"
      when 530 then return "YCbCrSubSampling"
      when 531 then return "YCbCrPositioning"
      when 532 then return "ReferenceBlackWhite"
      when 559 then return "StripRowCounts"
      when 700 then return "XMP"
      when 18246 then return "ImageRating"
      when 18249 then return "ImageRatingPercent"
      when 32781 then return "ImageID"
      when 32932 then return "WangAnnotation"
      when 33421 then return "CFARepeatPatternDim"
      when 33422 then return "CFAPattern"
      when 33423 then return "BatteryLevel"
      when 33432 then return "Copyright"
      when 33434 then return "ExposureTime"
      when 33437 then return "FNumber"
      when 33445 then return "MDFileTag"
      when 33446 then return "MDScalePixel"
      when 33447 then return "MDColorTable"
      when 33448 then return "MDLabName"
      when 33449 then return "MDSampleInfo"
      when 33450 then return "MDPrepDate"
      when 33451 then return "MDPrepTime"
      when 33452 then return "MDFileUnits"
      when 33550 then return "ModelPixelScaleTag"
      when 33723 then return "IPTCNAA"
      when 33918 then return "INGRPacketDataTag"
      when 33919 then return "INGRFlagRegisters"
      when 33920 then return "IrasBTransformationMatrix"
      when 33922 then return "ModelTiepointTag"
      when 34016 then return "Site"
      when 34017 then return "ColorSequence"
      when 34018 then return "IT8Header"
      when 34019 then return "RasterPadding"
      when 34020 then return "BitsPerRunLength"
      when 34021 then return "BitsPerExtendedRunLength"
      when 34022 then return "ColorTable"
      when 34023 then return "ImageColorIndicator"
      when 34024 then return "BackgroundColorIndicator"
      when 34025 then return "ImageColorValue"
      when 34026 then return "BackgroundColorValue"
      when 34027 then return "PixelIntensityRange"
      when 34028 then return "TransparencyIndicator"
      when 34029 then return "ColorCharacterization"
      when 34030 then return "HCUsage"
      when 34031 then return "TrapIndicator"
      when 34032 then return "CMYKEquivalent"
      when 34033 then return "Reserved"
      when 34034 then return "Reserved"
      when 34035 then return "Reserved"
      when 34264 then return "ModelTransformationTag"
      when 34377 then return "Photoshop"
      when 34665 then return "ExifIFD"
      when 34675 then return "InterColorProfile"
      when 34732 then return "ImageLayer"
      when 34735 then return "GeoKeyDirectoryTag"
      when 34736 then return "GeoDoubleParamsTag"
      when 34737 then return "GeoAsciiParamsTag"
      when 34850 then return "ExposureProgram"
      when 34852 then return "SpectralSensitivity"
      when 34853 then return "GPSInfo"
      when 34855 then return "ISOSpeedRatings"
      when 34856 then return "OECF"
      when 34857 then return "Interlace"
      when 34858 then return "TimeZoneOffset"
      when 34859 then return "SelfTimeMode"
      when 34864 then return "SensitivityType"
      when 34865 then return "StandardOutputSensitivity"
      when 34866 then return "RecommendedExposureIndex"
      when 34867 then return "ISOSpeed"
      when 34868 then return "ISOSpeedLatitudeyyy"
      when 34869 then return "ISOSpeedLatitudezzz"
      when 34908 then return "HylaFAXFaxRecvParams"
      when 34909 then return "HylaFAXFaxSubAddress"
      when 34910 then return "HylaFAXFaxRecvTime"
      when 36864 then return "ExifVersion"
      when 36867 then return "DateTimeOriginal"
      when 36868 then return "DateTimeDigitized"
      when 37121 then return "ComponentsConfiguration"
      when 37122 then return "CompressedBitsPerPixel"
      when 37377 then return "ShutterSpeedValue"
      when 37378 then return "ApertureValue"
      when 37379 then return "BrightnessValue"
      when 37380 then return "ExposureBiasValue"
      when 37381 then return "MaxApertureValue"
      when 37382 then return "SubjectDistance"
      when 37383 then return "MeteringMode"
      when 37384 then return "LightSource"
      when 37385 then return "Flash"
      when 37386 then return "FocalLength	"
      when 37387 then return "FlashEnergy"
      when 37388 then return "SpatialFrequencyResponse"
      when 37389 then return "Noise"
      when 37390 then return "FocalPlaneXResolution"
      when 37391 then return "FocalPlaneYResolution"
      when 37392 then return "FocalPlaneResolutionUnit"
      when 37393 then return "ImageNumber"
      when 37394 then return "SecurityClassification"
      when 37395 then return "ImageHistory"
      when 37396 then return "SubjectLocation"
      when 37397 then return "ExposureIndex"
      when 37398 then return "TIFFEPStandardID"
      when 37399 then return "SensingMethod"
      when 37500 then return "MakerNote"
      when 37510 then return "UserComment"
      when 37520 then return "SubsecTime"
      when 37521 then return "SubsecTimeOriginal"
      when 37522 then return "SubsecTimeDigitized	"
      when 37724 then return "ImageSourceData"
      when 40091 then return "XPTitle"
      when 40092 then return "XPComment"
      when 40093 then return "XPAuthor"
      when 40094 then return "XPKeywords"
      when 40095 then return "XPSubject"
      when 40960 then return "FlashpixVersion"
      when 40961 then return "ColorSpace"
      when 40962 then return "PixelXDimension"
      when 40963 then return "PixelYDimension	"
      when 40964 then return "RelatedSoundFile"
      when 40965 then return "InteroperabilityIFD"
      when 41483 then return "FlashEnergy"
      when 41484 then return "SpatialFrequencyResponse"
      when 41486 then return "FocalPlaneXResolution"
      when 41487 then return "FocalPlaneYResolution"
      when 41488 then return "FocalPlaneResolutionUnit"
      when 41492 then return "SubjectLocation"
      when 41493 then return "ExposureIndex"
      when 41495 then return "SensingMethod"
      when 41728 then return "FileSource"
      when 41729 then return "SceneType"
      when 41730 then return "CFAPattern"
      when 41985 then return "CustomRendered"
      when 41986 then return "ExposureMode"
      when 41987 then return "WhiteBalance"
      when 41988 then return "DigitalZoomRatio"
      when 41989 then return "FocalLengthIn35mmFilm"
      when 41990 then return "SceneCaptureType"
      when 41991 then return "GainControl"
      when 41992 then return "Contrast"
      when 41993 then return "Saturation"
      when 41994 then return "Sharpness"
      when 41995 then return "DeviceSettingDescription"
      when 41996 then return "SubjectDistanceRange"
      when 42016 then return "ImageUniqueID"
      when 42032 then return "CameraOwnerName"
      when 42033 then return "BodySerialNumber"
      when 42034 then return "LensSpecification"
      when 42035 then return "LensMake"
      when 42036 then return "LensModel"
      when 42037 then return "LensSerialNumber"
      when 42112 then return "GDALMETADATA"
      when 42113 then return "GDALNODATA"
      when 48129 then return "PixelFormat"
      when 48130 then return "Transformation"
      when 48131 then return "Uncompressed"
      when 48132 then return "ImageType"
      when 48256 then return "ImageWidth"
      when 48257 then return "ImageHeight"
      when 48258 then return "WidthResolution	"
      when 48259 then return "HeightResolution"
      when 48320 then return "ImageOffset"
      when 48321 then return "ImageByteCount"
      when 48322 then return "AlphaOffset"
      when 48323 then return "AlphaByteCount"
      when 48324 then return "ImageDataDiscard	"
      when 48325 then return "AlphaDataDiscard"
      when 50215 then return "OceScanjobDescription"
      when 50216 then return "OceApplicationSelector"
      when 50217 then return "OceIdentificationNumber"
      when 50218 then return "OceImageLogicCharacteristics"
      when 50341 then return "PrintImageMatching"
      when 50706 then return "DNGVersion"
      when 50707 then return "DNGBackwardVersion"
      when 50708 then return "UniqueCameraModel"
      when 50709 then return "LocalizedCameraModel"
      when 50710 then return "CFAPlaneColor"
      when 50711 then return "CFALayout"
      when 50712 then return "LinearizationTable"
      when 50713 then return "BlackLevelRepeatDim"
      when 50714 then return "BlackLevel"
      when 50715 then return "BlackLevelDeltaH"
      when 50716 then return "BlackLevelDeltaV"
      when 50717 then return "WhiteLevel"
      when 50718 then return "DefaultScale "
      when 50719 then return "DefaultCropOrigin	 "
      when 50720 then return "DefaultCropSize	"
      when 50721 then return "ColorMatrix1"
      when 50722 then return "ColorMatrix2"
      when 50723 then return "CameraCalibration1"
      when 50724 then return "CameraCalibration2"
      when 50725 then return "ReductionMatrix1"
      when 50726 then return "ReductionMatrix2"
      when 50727 then return "AnalogBalance"
      when 50728 then return "AsShotNeutral"
      when 50729 then return "AsShotWhiteXY"
      when 50730 then return "BaselineExposure"
      when 50731 then return "BaselineNoise"
      when 50732 then return "BaselineSharpness"
      when 50733 then return "BayerGreenSplit"
      when 50734 then return "LinearResponseLimit"
      when 50735 then return "CameraSerialNumber"
      when 50736 then return "LensInfo"
      when 50737 then return "ChromaBlurRadius"
      when 50738 then return "AntiAliasStrength"
      when 50739 then return "ShadowScale"
      when 50740 then return "DNGPrivateData"
      when 50741 then return "MakerNoteSafety"
      when 50778 then return "CalibrationIlluminant1"
      when 50779 then return "CalibrationIlluminant2"
      when 50780 then return "BestQualityScale"
      when 50781 then return "RawDataUniqueID"
      when 50784 then return "Alias Layer Metadata"
      when 50828 then return "OriginalRawFileData"
      when 50829 then return "ActiveArea"
      when 50830 then return "MaskedAreas"
      when 50831 then return "AsShotICCProfile"
      when 50832 then return "AsShotPreProfileMatrix"
      when 50833 then return "CurrentICCProfile	"
      when 50834 then return "CurrentPreProfileMatrix"
      when 50879 then return "ColorimetricReference"
      when 50931 then return "CameraCalibrationSignature"
      when 50932 then return "ProfileCalibrationSignature"
      when 50933 then return "ExtraCameraProfiles"
      when 50934 then return "AsShotProfileName"
      when 50935 then return "NoiseReductionApplied"
      when 50936 then return "ProfileName"
      when 50937 then return "ProfileHueSatMapDims"
      when 50938 then return "ProfileHueSatMapData1"
      when 50939 then return "ProfileHueSatMapData2"
      when 50940 then return "ProfileToneCurve"
      when 50941 then return "ProfileEmbedPolicy"
      when 50942 then return "ProfileCopyright"
      when 50964 then return "ForwardMatrix1"
      when 50965 then return "ForwardMatrix2"
      when 50966 then return "PreviewApplicationName"
      when 50967 then return "PreviewApplicationVersion"
      when 50968 then return "PreviewSettingsName"
      when 50969 then return "PreviewSettingsDigest"
      when 50970 then return "PreviewColorSpace"
      when 50971 then return "PreviewDateTime"
      when 50972 then return "RawImageDigest"
      when 50973 then return "OriginalRawFileDigest"
      when 50974 then return "SubTileBlockSize"
      when 50975 then return "RowInterleaveFactor"
      when 50981 then return "ProfileLookTableDims"
      when 50982 then return "ProfileLookTableData"
      when 51008 then return "OpcodeList1"
      when 51009 then return "OpcodeList2"
      when 51022 then return "OpcodeList3"
      when 51041 then return "NoiseProfile"
      when 51089 then return "OriginalDefaultFinalSize"
      when 51090 then return "OriginalBestQualityFinalSize"
      when 51091 then return "OriginalDefaultCropSize"
      when 51107 then return "ProfileHueSatMapEncoding"
      when 51108 then return "ProfileLookTableEncoding"
      when 51109 then return "BaselineExposureOffset"
      when 51110 then return "DefaultBlackRender"
      when 51111 then return "NewRawImageDigest"
      when 51112 then return "RawToPreviewGain"
      when 51125 then return "DefaultUserCrop"
      else
        return "Unknown #{value.to_s}"
      end
    end

    private def image_file_header
      file = @file.not_nil!
      puts file.gets(2)
      puts file.gets(2)
      data = file.gets(4)
      puts (data.not_nil!.to_unsafe.as Pointer(UInt32))[0]
    end
  
    private def image_file_directory
      file = @file.not_nil!
      puts "----------"
      file.pos = 8
      nextIFD = 8
      while nextIFD != 0
        nbrDirEntries = (file.gets(2).not_nil!.to_unsafe.as Pointer(UInt16))[0]
        print "Number of Directory Entries : ", nbrDirEntries, "\n"
        while nbrDirEntries != 0
          tag = (file.gets(2).not_nil!.to_unsafe.as Pointer(UInt16))[0]
          if tag == 0
            nextIFD = 0
            break
          end
          print "Tag   : ", self.tag_to_s(tag), "\n"
          print "Type  : ", self.type_to_s((file.gets(2).not_nil!.to_unsafe.as Pointer(UInt16))[0]), "\n"
          print "Count : ", (file.gets(4).not_nil!.to_unsafe.as Pointer(UInt32))[0], "\n"
          print "Value or Offset : ", (file.gets(4).not_nil!.to_unsafe.as Pointer(UInt32))[0], "\n"
          nbrDirEntries = nbrDirEntries - 1
        end
        break if nextIFD == 0
        nextIFD = (file.gets(4).not_nil!.to_unsafe.as Pointer(UInt32))[0]
        print "Offset of next IFD : ", nextIFD, "\n"
        file.pos = nextIFD
      end
    end
  end
end

image = Tiff::Tiff.new "/Users/nikolaiilodenos/Desktop/TCI.tif"

# puts image.header

puts "end"

# Header
# 0 - 1 : Order
# 2 - 3 : 42
# 4 - 7 : First IFD

# Image File Directory
# 0 - 1 : Tag
# 2 - 3 : Type
# 4 - 7 : Count
# 8 - 11 : Offset

# puts content[0..1]
# ptr8 = content.to_unsafe.as Pointer(UInt8)
# ptr16 = content.to_unsafe.as Pointer(UInt16)
# ptr32 = content.to_unsafe.as Pointer(UInt32)
