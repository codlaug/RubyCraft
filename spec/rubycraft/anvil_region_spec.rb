require 'rspec_helper'

describe RubyCraft::AnvilRegion do
  subject { described_class.fromFile(anvil) }
  let(:anvil) { File.expand_path('../../../fixtures/flat-r.0.0.mca', __FILE__) }

  it 'opens the file' do
    expect { subject }.not_to raise_error

    # loads chunks
    subject.chunk_string.count('X').should > 800
    # non-existing chunks
    subject.chunk_string.count('?').should > 100
  end
end
