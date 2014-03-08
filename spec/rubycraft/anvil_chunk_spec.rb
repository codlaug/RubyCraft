require 'rspec_helper'

describe RubyCraft::AnvilChunk do
  describe 'with sparse sections' do
    let(:anvil) { File.expand_path('../../../fixtures/flat-r.0.0.mca', __FILE__) }
    let(:region) { RubyCraft::AnvilRegion.fromFile(anvil) }
    let(:chunk)  { region.chunk(5,5) }

    it 'can parse and write Anvil format' do
      chunk.should be_a(RubyCraft::LazyChunk)

      b = chunk[2,2,2]
      b.should be_a(RubyCraft::Block)
    end

    xit "can iterate over all blocks and change them" do
      chunk = createSparseAnvilRegionChunk
      chunk.block_map do |block|
        if block.is :stone
          :gold
        else
          :air
        end
      end
      chunk.should have_only_block_of(:gold)
    end

    let(:total_blocks_in_chunk) { 16 * 256 * 16 }

    describe '#each_non_empty' do
      let(:chunk)  { region.chunk(0,0) } # not complete
      it 'may not yield nils when iterating over chunks' do
        count = 0
        chunk.each_non_empty do |block|
          block.should_not be_nil
          block.should be_a(RubyCraft::Block)
          count += 1
        end
        count.should be_between(20, total_blocks_in_chunk)
      end
      it 'yields chunk and its relative position'
    end

    describe '#each' do
      it 'may yield blocks from lazysections to be set, saved only when touched' do
        count = 0
        chunk.each do |block|
          block.should be_a(RubyCraft::Block)
          count += 1
        end
        count.should == total_blocks_in_chunk
      end
    end

  end
end

