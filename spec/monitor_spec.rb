# frozen_string_literal: true

RSpec.describe Vendi::Monitor do
  before(:all) do
    @v = set_vendi
  end

  it 'get_transactions_to_process 1' do
    txs = %i[tx1 tx2 tx3]
    txs_new = %i[tx_new1 tx1 tx2 tx3]
    to_proc = @v.get_transactions_to_process(txs_new, txs)
    expect(to_proc).to eq [:tx_new1]
  end

  it 'get_transactions_to_process 2' do
    txs = %i[tx1 tx2 tx3]
    txs_new = %i[tx_new1 tx_new2 tx1 tx2 tx3]
    to_proc = @v.get_transactions_to_process(txs_new, txs)
    expect(to_proc).to eq %i[tx_new1 tx_new2]
  end

  it 'get_transactions_to_process 5' do
    txs = %i[tx1 tx2 tx3]
    txs_new = %i[tx_new1 tx_new2 tx_new3 tx_new4 tx_new5 tx1 tx2 tx3]
    to_proc = @v.get_transactions_to_process(txs_new, txs)
    expect(to_proc).to eq %i[tx_new1 tx_new2 tx_new3 tx_new4 tx_new5]
  end
end
