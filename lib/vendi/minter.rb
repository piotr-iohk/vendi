# frozen_string_literal: true

module Vendi
  # helper methods for minting NFT
  module Minter
    ##
    # encode string asset_name to hex representation
    def asset_name(asset_name)
      asset_name.unpack1('H*')
    end

    ##
    # get list of keys of metadata to be minted
    def keys_to_mint(tx_amt, price, vend_max, collection_name)
      nfts = metadata_vending(collection_name)
      to_mint = (tx_amt / price) > vend_max.to_i ? vend_max.to_i : (tx_amt / price)
      nfts.keys.sample(to_mint)
    end

    ##
    # get metadata for keys to be minted
    def metadatas(keys, collection_name)
      nfts = metadata_vending(collection_name)
      keys.to_h do |key|
        [key, nfts[key]]
      end
    end

    ##
    # prepare metadata for minting
    def prepare_metadata(keys, collection_name, policy_id)
      {
        '721' => {
          policy_id => metadatas(keys, collection_name)
        }
      }
    end

    ##
    # update metadata files after minting
    def update_metadata_files(keys, collection_name)
      metadata_vending_file = metadata_vending_path(collection_name)
      metadata_sent_file = metadata_sent_path(collection_name)
      # metadata sent
      m = metadatas(keys, collection_name)
      if File.exist? metadata_sent_file
        sent = from_json(metadata_sent_file)
        sent.merge!(m)
        to_json(metadata_sent_file, sent)
      else
        to_json(metadata_sent_file, m)
      end
      # metadata available
      nfts = metadata_vending(collection_name)
      keys.each do |key|
        nfts.delete(key)
      end
      to_json(metadata_vending_file, nfts)
    end

    # Build mint payload for construct tx
    def mint_payload(keys, address, quantity = 1)
      keys.map do |key|
        { 'operation' => { 'mint' => { 'quantity' => quantity,
                                       'receiving_address' => address } },
          'policy_script_template' => Vendi::POLICY_SCRIPT_TEMPLATE,
          'asset_name' => asset_name(key.to_s) }
      end
    end

    # Construct -> Sign -> Submit transaction
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

    # Mint NFT 
    def mint_nft(collection_name, tx_amt, vend_max, dest_address)
      c = config(collection_name)
      wid = c[:wallet_id]
      pass = c[:wallet_pass]
      policy_id = c[:policy_id]
      price = c[:price]
      keys = keys_to_mint(tx_amt, price, vend_max, collection_name)
      @logger.info "Minting #{keys.size} NFT(s): #{keys} to #{dest_addr}"
      metadata = prepare_metadata(keys, collection_name, policy_id)
      mint_payload = mint_payload(keys, dest_address, 1)
      construct_sign_submit(wid, pass, metadata, mint_payload)
    end

    ##
    # check if NFT mint transaction is successful 
    def outgoing_tx_ok?(tx_res)
      tx_constructed, tx_signed, tx_submitted = tx_res
      tx_constructed.code == 202 && tx_signed.code == 202 && tx_submitted.code == 202
    end
    
    ##
    # wait for NFT to be minted
    def wait_for_tx_in_ledger(wid, tx_id)
      eventually "Tx #{tx_id} is in ledger" do
        @logger.info "Waiting for #{tx_id} to get in_ledger"
        tx = @cw.shelley.transactions.get(wid, tx_id)
        tx.code == 200 && tx['status'] == 'in_ledger'
      end
    end
  end
end
