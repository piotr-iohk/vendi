# frozen_string_literal: true

RSpec.describe Vendi::Minter do
  before(:all) do
    @v = set_vendi
  end

  it 'update_metadata_files' do
    coll = 'TestBudz'
    @v.fill(coll, 10_000_000, 5, skip_wallet: true)
    expect(@v.metadata(coll).size).to eq 5

    @v.set_metadata_vending(coll, @v.metadata(coll))
    expect(@v.metadata(coll)).to eq @v.metadata_vending(coll)

    # only 1
    @v.update_metadata_files([:TestBudz_3], coll)

    expect(@v.metadata(coll).size).to eq 5
    expect(@v.metadata_vending(coll).size).to eq 4
    expect(@v.metadata_sent(coll).size).to eq 1
    expect(@v.metadata_sent(coll)[:TestBudz_3]).not_to be_empty

    # more than 1
    @v.update_metadata_files(%i[TestBudz_4 TestBudz_1 TestBudz_5], coll)

    expect(@v.metadata(coll).size).to eq 5
    expect(@v.metadata_vending(coll).size).to eq 1
    expect(@v.metadata_sent(coll).size).to eq 4
    expect(@v.metadata_sent(coll)[:TestBudz_4]).not_to be_empty
    expect(@v.metadata_sent(coll)[:TestBudz_5]).not_to be_empty
    expect(@v.metadata_sent(coll)[:TestBudz_3]).not_to be_empty
    expect(@v.metadata_sent(coll)[:TestBudz_1]).not_to be_empty
  end

  it 'prepare_metadata' do
    coll = 'TestBudz44'
    @v.fill(coll, 10_000_000, 10, skip_wallet: true)

    keys = [:TestBudz44_1]
    metadata = @v.prepare_metadata(keys, coll, 'policy_id')
    expect(metadata).to have_key('721')
    expect(metadata.to_s).to include('TestBudz44_1')
    expect(metadata.to_s).to include('policy_id')

    keys2 = %i[TestBudz_4 TestBudz_7 TestBudz_5]
    metadata2 = @v.prepare_metadata(keys2, coll, 'policy_id')
    expect(metadata2).to have_key('721')
    expect(metadata2.to_s).to include('TestBudz_4')
    expect(metadata2.to_s).to include('TestBudz_7')
    expect(metadata2.to_s).to include('TestBudz_5')
    expect(metadata2.to_s).to include('policy_id')

  end
end
