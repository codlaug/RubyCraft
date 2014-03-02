# Patching nbtfile clases so that they don't gzip/ungzip incorrectly the zlib bytes from
#mcr files. Use the methods from ZlibHelper
#
# FIXME is this still neccessary?
module RubyCraft
  module ZlibHelper
    def compress(str)
      Zlib::Deflate.deflate(str)
    end

    def decompress(str)
      Zlib::Inflate.inflate(str)
    end
    extend self
  end
end
