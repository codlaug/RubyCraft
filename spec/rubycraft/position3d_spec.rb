require 'rspec_helper'

describe RubyCraft::Position3D do

  describe 'at 1,2,3' do
    let(:x) { 1 }
    let(:y) { 2 }
    let(:z) { 3 }

    subject { described_class.new x, y, z }
    its(:x) { should == x }
    its(:y) { should == y }
    its(:z) { should == z }

    it 'equals when all coordiantes match' do
      should == described_class.new(x,y,z)
    end

    it 'does not equal when one coordinate differs' do
      should_not == described_class.new(x,y,z+1)
    end

    it 'does not equal when only one coordiante is the same' do
      should_not == described_class.new(x+1,y,z+1)
    end

    it 'can be created from Array as y, z, x' do
      [y,z,x].yzx.should == subject
    end

    it 'can be created from Array as x, z, y' do
      [x,z,y].xzy.should == subject
    end
  end

  it 'can not be created from two-dimensional array' do
    expect { [1,1].yzx }.to raise_error(ArgumentError)
  end

end

