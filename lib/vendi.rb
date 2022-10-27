# frozen_string_literal: true

require 'logger'
require 'fileutils'
require 'cardano_wallet'
require 'vendi/version'
require 'vendi/utils'
require 'vendi/monitor'
require 'vendi/minter'
require 'vendi/machine'

# Vendi CNFT Vending machine
module Vendi
  # Timeout for tx to get into ledger
  TIMEOUT = 300

  POLICY_SCRIPT_TEMPLATE = 'cosigner#0'

  def self.init(wallet_opts = {}, log_level = :info, logfile = nil)
    Vendi::Machine.new(wallet_opts, log_level, logfile)
  end
end
