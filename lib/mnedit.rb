#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'
require 'chunk'
require 'stringio'
require 'zlib'
require 'byte_converter'
class ChunkCounter
  attr_reader :x, :y, :z

  def initialize
    @y = 0
    @z = 0
    @x = 0
  end

  def inc
    @y += 1
    if @y == 128
      @y = 0
      @z += 1
    end
    if @z == 16
      @z = 0
      @x += 1
    end
    pos
  end

  def pos
    [@y, @z, @x]
  end

end


class PlaneCounter
  attr_reader :x, :z
  def initialize
    @x = 0
    @z = 0
  end

  def inc
    @x += 1
    if @x == 32
      @x = 0
      @z += 1
    end
    pos
  end

  def pos
    [@x, @z]
  end

end


class Region
  include ByteConverter
  include ZlibHelper

  attr_accessor :bytes
  attr_accessor :file

  def initialize(file)
    @bytes = stringToByteArray IO.read(file)
    @file = file
  end

  def write
    File.open(@file, "wb") do |f|
      f << bytes.pack("C*")
    end
    self
  end

  def printspecs
    counter = PlaneCounter.new
    bytes[0..4095].each_slice(4) do |ar|
      p ar
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      x, y = counter.pos
      puts "[#{x}, #{y}] : #{offset}, count = #{count}"
      counter.inc
    end
  end

  def convertChunks(&block)
    chunkMetaDataSize = 5
    dummytimestamp = 0
    chunks = []
    counter = PlaneCounter.new
    bytes[0..4095].each_slice(4) do |ar|
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      if count > 0
        puts "at offset: #{offset}"
        chunks << convertChunk(offset, counter.pos, &block)
      else
        chunks << nil
      end
      counter.inc
    end
    newBytes = []
    lastVacantPosition = 2
    for chunk in chunks
      if chunk
        offset = lastVacantPosition
        sizeCount = ((chunk.size + chunkMetaDataSize).to_f / 4096).ceil
        lastVacantPosition += sizeCount
        concat newBytes, intBytes(offset)[1..3]
        newBytes << sizeCount
      else
        pad newBytes, 4
      end
    end
    defaultCompressionType = 2
    pad newBytes, 4096, dummytimestamp
    for chunk in chunks
      next if chunk.nil?
      concat newBytes, intBytes(chunk.size + 1)
      newBytes << defaultCompressionType
      concat newBytes, chunk
      size = (chunk.size + chunkMetaDataSize)
      remaining = 4096 - (size % 4096)
      pad newBytes, remaining % 4096
    end
    File.open(@file, "wb") do |f|
      f << newBytes.pack("C*")
    end
  end

  def convertChunk(offset, pos, &block)
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    return nbtBytes unless block_given? and block.call(pos)
    puts "converting: #{pos.inspect}"
    nbtdata = readnbt nbtBytes
    c = Chunk.new nbtdata
    c.each do |b|
      if b.y == 63
        b.name = :wool
        b.data = (b.x + b.z) % 16
      end
    end
    output = StringIO.new
    name, body = c.export
    NBTFile.write(output, name, body)
    out = stringToByteArray compress(output.string)
    return out
  end

  def getNbt(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    readnbt nbtBytes
  end

  def readChunk(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    puts "Its sector count is  #{bytes[o + 3]}"
    puts "the offset is: #{offset}"
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    puts "It has size: #{bytecount}"
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    printNbt(nbtBytes)
  end

  def printNbt(nbtBytes)
    name, body = readnbt nbtBytes
    blocks = body['Level']['Blocks'].value.bytes.to_a
    datavalues = body['Level']['Data'].value.bytes.to_a
    
    counter = ChunkCounter.new
    puts "-> Blocks x Data"
    index = 0
    while index < 32768
      b = blocks[index]
      name = Block.get(b).name
      data = datavalues[index / 2]
      datavalue = if index % 2 == 1
        data & 0xF #tail 
      else
        data >> 4 #head
      end
      puts "#{counter.pos.inspect}: #{name}, data = #{datavalue}"
      counter.inc
      index += 1
    end

    counter = ChunkCounter.new
    data = body['Level']['Data']
    data.value.bytes.each do |b|
      head = b >> 4
      tail = b & 0xF
      puts "data At #{counter.pos.inspect} is #{head}"
      counter.inc
      puts "data At #{counter.pos.inspect} is #{tail}"
      counter.inc
      puts "!!!the full data is #{b}" if b != 0
    end

    puts "-> Height map"
    heightmap = body['Level']['HeightMap']
    x = 0
    z = 0
    heightmap.value.bytes.each do |h|
      puts "At [#{x}, #{z}]: #{h}"
      x += 1
      if x == 16
        z += 1
        x = 0
      end
    end
    l = body['Level']
    puts "-> LastUpdate: #{l['LastUpdate'].value }"
    puts "-> Poxes: #{l["zPos"].value}, #{l["xPos"].value}"
  end

  def change(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    name, body = readnbt nbtBytes
    blocks = body['Level']['Blocks']
    newarray = blocks.value.bytes.map do |b|
      8
    end
    body['Level']['Blocks'] = NBTFile::Types::ByteArray.new newarray.pack("C*")
    output = StringIO.new
    NBTFile.write(output, name, body)
    @bytes[offset..(offset + bytecount - 2)] = stringToByteArray compress(output.string)
    self
  end

  protected
  def readnbt(bytes)
    NBTFile.read  stringToIo decompress(toByteString(bytes))
  end

end
