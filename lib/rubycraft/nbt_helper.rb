require 'nbtfile'
require 'zlib'

module RubyCraft
  # Handles converting bytes to/from nbt regions, which are compressesed/decompress
  module NbtHelper
    extend ByteConverter
    extend ZlibHelper

    module_function
    def fromNbt(bytes)
      NBTFile.read stringToIo decompress toByteString bytes
    end

    def toBytes(nbt)
      output = StringIO.new
      name, body = nbt
      NBTFile.write(output, name, body)
      stringToByteArray compress output.string
    end
  end
end
