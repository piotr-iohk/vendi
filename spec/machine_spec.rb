# frozen_string_literal: true

RSpec.describe Vendi::Machine do
  before(:all) do
    @v = set_vendi
  end

  it 'fill' do
    coll = 'TestBudz'
    @v.fill(coll, 10_000_000, 100, skip_wallet: true)
    expect(@v.config(coll)[:price]).to eq 10_000_000
    expect(@v.metadata(coll).size).to eq 100
    expect(@v.metadata(coll)[:TestBudz_1]).not_to be_empty
    expect(@v.metadata(coll)[:TestBudz_100]).not_to be_empty
    expect(@v.metadata(coll)[:TestBudz_101]).to be nil
  end

  it 'metadata_vending' do
    coll = 'TestBudz2'
    @v.fill(coll, 10_000_000, 1, skip_wallet: true)
    @v.set_metadata_vending(coll, { Test: { img: 'ipfs://xxxyyyzzz' } })
    expect(@v.metadata_vending(coll).size).to eq 1
    expect(@v.metadata_vending(coll)[:Test]).not_to be_empty
  end

  it 'metadata_sent' do
    coll = 'TestBudz2'
    @v.fill(coll, 10_000_000, 1, skip_wallet: true)
    @v.set_metadata_sent(coll, { Test: { img: 'ipfs://xxxyyyzzz' } })
    expect(@v.metadata_sent(coll).size).to eq 1
    expect(@v.metadata_sent(coll)[:Test]).not_to be_empty
  end
end
