# frozen_string_literal: true

module Vendi
  # helper methods for monitoring incoming transactions
  module Monitor
    def get_incoming_txs(wid)
      @cw.shelley.transactions.list(wid).select { |t| t['direction'] == 'incoming' }
    end

    def get_transactions_to_process(txs_delta, txs)
      old_tx_ids = txs.map { |t| t['id'] }
      txs_delta.reject { |t| old_tx_ids.include?(t['id']) }
    end

    # incoming tx is correct when the address is on any of the outputs (means that someone was sending to it)
    # and tx amount is >= price set in the config
    def incoming_tx_ok?(tx, address, price)
      (tx['outputs'].any? { |o| (o['address'] == address) }) && (tx['amount']['quantity'] >= price)
    end

    # trying to naively get address to send back NFT, take first address from the output that isn't our address
    # assuming that it is a change address
    def get_dest_addr(tx, address)
      output_dest_addr = tx['outputs'].map { |o| o['address'] }.reject { |a| a == address }.first

      # if no address in outputs try to get one from inputs
      output_dest_addr || tx['inputs'].map { |o| o['address'] }.reject { |a| a == address }.first
    end
  end
end
