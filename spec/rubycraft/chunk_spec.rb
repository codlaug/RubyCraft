require 'rspec_helper'

describe RubyCraft::Chunk do
  describe 'dimensions' do
    let(:binary) { double('Binary').as_null_object }
    let(:name)   { 'a Test Chunk' }
    let(:nbt)    { [name, binary] }

    it 'defaults to old minecraft' do
       chunk = described_class.new nbt, no_blocks: true
       chunk.dimensions.should == [16, 16, 128]
    end

    it 'can be overriden for more performant tests' do
       chunk = described_class.new nbt, chunk_dimensions: [1,2,3], no_blocks: true
       chunk.dimensions.should == [1,2,3]
    end
  end
end

