# frozen_string_literal: true

RSpec.describe Vendi::Minter do
  before(:all) do
    @v = set_vendi
  end

  it 'update_metadata_files' do
    coll = 'TestBudz'
    @v.fill(coll, 10_000_000, 100, skip_wallet: true)
    expect(@v.metadata(coll).size).to eq 100

    @v.set_metadata_vending(coll, @v.metadata(coll))
    expect(@v.metadata(coll)).to eq @v.metadata_vending(coll)

    @v.update_metadata_files(@v.metadata(coll), :TestBudz_44,
                             @v.metadata_vending_path(coll),
                             @v.metadata_sent_path(coll))

    expect(@v.metadata(coll).size).to eq 100
    expect(@v.metadata_vending(coll).size).to eq 99
    expect(@v.metadata_sent(coll).size).to eq 1
    expect(@v.metadata_sent(coll)[:TestBudz_44]).not_to be_empty
  end

  it 'prepare_metadata' do
    coll = 'TestBudz44'
    @v.fill(coll, 10_000_000, 1, skip_wallet: true)
    nfts = @v.metadata(coll)
    key = :TestBudz44_1

    metadata = @v.prepare_metadata(nfts, key, 'policy_id')
    expect(metadata).to have_key('721')
    expect(metadata.to_s).to include('TestBudz44_1')
    expect(metadata.to_s).to include('policy_id')
  end
end
