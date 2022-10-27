# frozen_string_literal: true

module Vendi
  # general utility methods
  module Utils
    def from_json(file)
      JSON.parse(File.read(file), { symbolize_names: true })
    end

    def to_json(file, hash)
      File.write(file, JSON.pretty_generate(hash))
    end

    def as_ada(quantity)
      res = quantity.to_f / 1_000_000
      str_res = format('%.7f', res)
      last = str_res[-1]
      final = ''
      until last == '.'
        str_res.chop!
        if last == '0'
          final = str_res
          break unless final[-1] == '0'
        end
        last = str_res[-1]
      end
      final.chop! if final[-1] == '.'
      "#{final} ₳"
    end

    ##
    # wait until action passed as &block returns true or TIMEOUT is reached
    def eventually(label, &block)
      current_time = Time.now
      timeout_treshold = current_time + Vendi::TIMEOUT
      while (block.call == false) && (current_time <= timeout_treshold)
        sleep 5
        current_time = Time.now
      end
      if current_time > timeout_treshold
        @logger.error "Action '#{label}' did not resolve within timeout: #{Vendi::TIMEOUT}s"
        false
      else
        true
      end
    end

    ##
    # encode string asset_name to hex representation
    def asset_name(asset_name)
      asset_name.unpack1('H*')
    end
  end
end
