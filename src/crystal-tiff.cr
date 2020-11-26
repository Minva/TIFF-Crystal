# TODO: Write documentation for `Crystal::Tiff`
module Tiff
  VERSION = "0.1.0"
  extend self
end




# Image_File_Header

# Image File Directory


content = File.open("/Users/nikolaiilodenos/Desktop/TCI.tif") do |file|
  file.gets_to_end
end






puts content[0].as_i, content[1].as_i