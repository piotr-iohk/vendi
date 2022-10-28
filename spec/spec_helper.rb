# frozen_string_literal: true

require 'bundler/setup'
require 'vendi'
require 'tmpdir'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def set_vendi
  v = Vendi.init({}, :error)
  v.config_dir = Dir.mktmpdir
  v
end
