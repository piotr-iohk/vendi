# frozen_string_literal: true

module Vendi
  # helper methods for minting NFT
  module Minter
    def prepare_metadata(nfts, key, policy_id)
      {
        '721' => {
          policy_id => {
            key => nfts[key]
          }
        }
      }
    end

    def update_metadata_files(nfts, key, metadata_vending_file, metadata_sent_file)
      # metadata sent
      m = { key => nfts[key] }
      if File.exist? metadata_sent_file
        sent = from_json(metadata_sent_file)
        sent.merge!(m)
        to_json(metadata_sent_file, sent)
      else
        to_json(metadata_sent_file, m)
      end
      # metadata available
      nfts.delete(key)
      to_json(metadata_vending_file, nfts)
    end

    # Build mint payload for construct tx
    def mint_payload(asset_name, address, quantity = 1)
      mint = { 'operation' => { 'mint' => { 'quantity' => quantity,
                                            'receiving_address' => address } },
               'policy_script_template' => Vendi::POLICY_SCRIPT_TEMPLATE }
      mint['asset_name'] = asset_name unless asset_name.nil?
      [mint]
    end

    # Construct -> Sign -> Submit
    def construct_sign_submit(wid, pass, metadata, mint_payload)
      tx_constructed = @cw.shelley.transactions.construct(wid,
                                                          nil,
                                                          nil,
                                                          metadata,
                                                          nil,
                                                          mint_payload,
                                                          nil)
      # puts tx_constructed.request.options[:body]
      tx_signed = @cw.shelley.transactions.sign(wid, pass, tx_constructed['transaction'])
      # puts tx_signed
      tx_submitted = @cw.shelley.transactions.submit(wid, tx_signed['transaction'])
      # puts tx_submitted

      [tx_constructed, tx_signed, tx_submitted]
    end

    def outgoing_tx_ok?(tx_res)
      tx_constructed, tx_signed, tx_submitted = tx_res
      tx_constructed.code == 202 && tx_signed.code == 202 && tx_submitted.code == 202
    end

    def wait_for_tx_in_ledger(wid, tx_id)
      eventually "Tx #{tx_id} is in ledger" do
        @logger.info "Waiting for #{tx_id} to get in_ledger"
        tx = @cw.shelley.transactions.get(wid, tx_id)
        tx.code == 200 && tx['status'] == 'in_ledger'
      end
    end
  end
end
