# frozen_string_literal: true

module Vendi
  # Vending Machine: fill it with NFTs and serve to the hungry and in need!
  class Machine
    include Vendi::Utils
    include Vendi::Monitor
    include Vendi::Minter

    attr_reader :logger, :cw, :config_dir

    def initialize(wallet_opts = {}, log_level = :info, log_file = nil)
      @cw = CardanoWallet.new(wallet_opts)
      progname = 'vendi'
      datetime_format = '%Y-%m-%d %H:%M:%S'
      @logger = if log_file
                  Logger.new(log_file,
                             'daily',
                             # shift_size = 10,
                             progname: progname,
                             level: log_level,
                             datetime_format: datetime_format)
                else
                  Logger.new($stdout,
                             progname: progname,
                             level: log_level,
                             datetime_format: datetime_format)
                end
      @config_dir = File.join(Dir.home, '.vendi-nft-machine')
    end

    def collection_dir(collection_name)
      File.join(@config_dir, collection_name)
    end

    def config_path(collection_name)
      File.join(collection_dir(collection_name), 'config.json')
    end

    def metadata_path(collection_name)
      File.join(collection_dir(collection_name), 'metadata.json')
    end

    def metadata_vending_path(collection_name)
      File.join(collection_dir(collection_name), 'metadata-vending.json')
    end

    def metadata_sent_path(collection_name)
      File.join(collection_dir(collection_name), 'metadata-sent.json')
    end

    def config(collection_name)
      from_json(config_path(collection_name))
    end

    def metadata_vending(collection_name)
      from_json(metadata_vending_path(collection_name))
    end

    def metadata_sent(collection_name)
      from_json(metadata_sent_path(collection_name))
    end

    def metadata(collection_name)
      from_json(metadata_path(collection_name))
    end

    def set_metadata(collection_name, metadata)
      to_json(metadata_path(collection_name), metadata)
    end

    def set_metadata_sent(collection_name, metadata)
      to_json(metadata_sent_path(collection_name), metadata)
    end

    def set_metadata_vending(collection_name, metadata)
      to_json(metadata_vending_path(collection_name), metadata)
    end

    def set_config(collection_name, configuration)
      to_json(config_path(collection_name), configuration)
    end

    # Fill vending machine with exemplary set of CIP-25 metadata for minting,
    # set up basic config and create wallet for minting
    def fill(collection_name, price, nft_count)
      FileUtils.mkdir_p(collection_dir(collection_name))
      @logger.info('Generating wallet for your collection.')
      wallet_details = create_wallet("Vendi wallet - #{collection_name}")

      @logger.info("Generating your NFT collection config into #{config_path(collection_name)}.")
      @logger.info("NFT price: #{as_ada(price.to_i)}.")
      config = { price: price.to_i }
      mnemonics = wallet_details[:wallet_mnemonics]
      wallet_details.delete(:wallet_mnemonics)
      config.merge!(wallet_details)
      set_config(collection_name, config)

      @logger.info("Generating exemplary CIP-25 metadata set into #{metadata_path(collection_name)}.")
      metadatas = generate_metadata(collection_name, nft_count.to_i)
      set_metadata(collection_name, metadatas)

      @logger.info('IMPORTANT NOTES! 👇')
      @logger.info('----------------')
      @logger.info("Check contents of #{collection_dir(collection_name)} and edit files as needed.")
      @logger.info('Before starting vending machine make sure your wallet is synced and has enough funds.')
      @logger.info("To fund your wallet send ADA to: #{wallet_details[:wallet_address]}")
      @logger.info("❗ Write down your wallet mnemonics: #{mnemonics}.")
    end

    # Turn on vending machine and make it serve NFTs for anyone who dares to
    # pay the 'price' to the 'address', that is specified in the config_file
    def serve(collection_name)
      set_metadata_sent(collection_name, {}) unless File.exist?(metadata_sent_path(collection_name))

      c = config(collection_name)
      wid = c[:wallet_id]
      pass = c[:wallet_pass]
      address = c[:wallet_address]
      policy_id = c[:wallet_policy_id]
      price = c[:price]
      wallet = @cw.shelley.wallets.get(wid)

      raise "Wallet #{wid} does not exist!" if wallet.code == 404
      raise "Wallet #{wid} is not synced (#{wallet['state']})!" if wallet['state']['status'] != 'ready'
      raise "Wallet #{wid} has no funds!" if (wallet['balance']['available']['quantity']).zero?

      @logger.info 'Vending machine started.'
      @logger.info "Wallet id: #{wid}"
      @logger.info "Address: #{address}"
      @logger.info "NFT price: #{as_ada(price)}"
      @logger.info "Original NFT stock: #{metadata(collection_name).size}"
      @logger.info '----------------'
      unless File.exist?(metadata_vending_path(collection_name))
        @logger.info "Making copy of #{metadata_path(collection_name)} to #{metadata_vending_path(collection_name)}."
        FileUtils.cp(metadata_path(collection_name), metadata_vending_path(collection_name))
      end

      txs = get_incoming_txs(wid)
      until metadata_vending(collection_name).empty?
        nfts = metadata_vending(collection_name)
        nfts_sent = metadata_sent(collection_name)
        wallet_balance = @cw.shelley.wallets.get(wid)['balance']['available']['quantity']
        @logger.info "Vending machine [In stock: #{nfts.size}, Sent: #{nfts_sent.size}, NFT price: #{as_ada(price)}, Balance: #{as_ada(wallet_balance)}]"

        txs_delta = get_incoming_txs(wid)
        if txs.size < txs_delta.size
          txs_to_check = txs_delta[0..(txs_delta.size - txs.size - 1)]
          @logger.info "New txs arrived: #{txs_to_check.size}"
          @logger.info (txs_to_check.map { |t| t['id'] }).to_s

          txs_to_check.each do |t|
            @logger.info "Checking #{t['id']}"
            if incoming_tx_ok?(t, address, price)
              @logger.info 'OK! VENDING!'
              @logger.info '----------------'
              dest_addr = get_dest_addr(t, address)

              # prepare metadata and mint payload
              key = nfts.keys.sample
              metadata = prepare_metadata(nfts, key, policy_id)
              mint = mint_payload(asset_name(key.to_s), dest_addr)
              @logger.debug JSON.pretty_generate(metadata)
              @logger.debug JSON.pretty_generate(mint)

              # mint
              @logger.info "Minting NFT: #{key} to #{dest_addr}"
              tx_res = construct_sign_submit(wid, pass, metadata, mint)
              if outgoing_tx_ok?(tx_res)
                mint_tx_id = tx_res.last['id']
                wait_for_tx_in_ledger(wid, mint_tx_id)
                # update metadata files
                update_metadata_files(nfts, key, metadata_vending_path(collection_name), metadata_sent_path(collection_name))
              else
                @logger.error 'Minting tx failed!'
                @logger.error "Construct tx: #{JSON.pretty_generate(tx_res[0])}"
                @logger.error "Sign tx: #{JSON.pretty_generate(tx_res[1])}"
                @logger.error "Submit tx: #{JSON.pretty_generate(tx_res[2])}"
              end
              @logger.info '----------------'

            else
              @logger.warn "NO GOOD! NOT VENDING! Tx: #{t['id']}"
            end
          end

          txs = txs_delta
        end

        sleep 5
      end
      @logger.info 'Turning off! Vending machine empty!'
    end

    private

    def create_wallet(wallet_name = nil, wallet_pass = nil, wallet_mnemonics = nil)
      wallet_name ||= 'Vendi wallet'
      wallet_mnemonics ||= @cw.utils.mnemonic_sentence
      wallet_pass ||= 'Secure Passphrase'
      wallet = @cw.shelley.wallets.create({ name: wallet_name,
                                            mnemonic_sentence: wallet_mnemonics,
                                            passphrase: wallet_pass })

      @logger.debug('!!!!! Write down wallet mnemonics !!!!')
      @logger.debug(wallet_mnemonics.to_s)
      wid = wallet['id']
      wallet_address = @cw.shelley.addresses.list(wid).first['id']
      wallet_policy_id = @cw.shelley.keys.create_policy_id(wid, Vendi::POLICY_SCRIPT_TEMPLATE)['policy_id']
      { wallet_id: wallet['id'],
        wallet_name: wallet_name,
        wallet_pass: wallet_pass,
        wallet_address: wallet_address,
        wallet_policy_id: wallet_policy_id,
        wallet_mnemonics: wallet_mnemonics }
    end

    def generate_metadata(nft_name_prefix, nft_count)
      metadata = {}
      1.upto nft_count do |i|
        nft_metadata = {
          "#{nft_name_prefix}_#{i}" => {
            'name' => "#{nft_name_prefix.upcase} No #{i}",
            'image' => 'ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw',
            'Copyright' => "Vendi #{Time.now.year}",
            'Collection' => "#{nft_name_prefix} #{Time.now.year}"
          }
        }
        metadata.merge!(nft_metadata)
      end
      metadata
    end
  end
end
