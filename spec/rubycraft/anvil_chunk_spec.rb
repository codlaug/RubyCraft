require 'rspec_helper'

describe RubyCraft::AnvilChunk do
  describe 'with sparse sections' do
    let(:anvil) { File.expand_path('../../../fixtures/flat-r.0.0.mca', __FILE__) }
    it 'can parse and write Anvil format' do
      region = RubyCraft::AnvilRegion.fromFile(anvil)
      chunk = region.chunk(5,5)
      chunk.should be_a(RubyCraft::LazyChunk)

      block = chunk[5,5,5]
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


    it 'may not yield nils when iterating over chunks'
    it 'may yield blocks from lazysections to be set, saved only when touched'
  end
end

