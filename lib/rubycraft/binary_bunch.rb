module RubyCraft
  # A Collection of Bytes, accepting options
  class BinaryBunch
    include Enumerable
    include ByteConverter
    include ZlibHelper
    def self.from_file(filename)
      path = Pathname.new(filename).expand_path
      if path.extname == '.mca'
        AnvilRegion
      else
        ScaevolusRegion
      end.fromFile(path)
    end

    def self.fromFile(filename)
      new ByteConverter.stringToByteArray IO.read filename
    end

    attr_reader :options
    def initialize(bytes, options = {})
      raise "Must be an io" if bytes.kind_of?(String)
      @bytes = bytes
      @options = options
    end

    def inspect
      %Q~<#{self.class} (#{@bytes.length} bytes)>~
    end

    def exportToFile(filename)
      File.open(filename, "wb") { |f| exportTo f }
    end
  end
end
