# frozen_string_literal: true

module Vendi
  # helper methods for monitorint incoming transactions
  module Monitor
    def get_incoming_txs(wid)
      @cw.shelley.transactions.list(wid).select { |t| t['direction'] == 'incoming' }
    end

    def get_transactions_to_process(txs_delta, txs)
      old_tx_ids = txs.map { |t| t['id'] }
      txs_delta.reject { |t| old_tx_ids.include?(t['id']) }
    end

    def tx_correct?(tx, address, amount)
      tx['outputs'].any? { |o| (o['address'] == address) && (o['amount']['quantity'] == amount) }
    end

    def get_dest_addr(tx, address)
      output_dest_addr = tx['outputs'].map { |o| o['address'] }.reject { |a| a == address }.first

      # if no address in outputs try to get one from inputs
      output_dest_addr || tx['inputs'].map { |o| o['address'] }.reject { |a| a == address }.first
    end
  end
end
