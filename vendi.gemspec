# frozen_string_literal: true

require_relative 'lib/vendi/version'

Gem::Specification.new do |spec|
  spec.name          = 'vendi'
  spec.version       = Vendi::VERSION
  spec.authors       = ['Piotr Stachyra']
  spec.email         = ['piotr.stachyra@gmail.com']

  spec.summary       = 'CNFT Vending Machine - cardano-wallet based'
  spec.description   = 'CNFT Vending Machine - cardano-wallet based'
  spec.homepage      = 'https://github.com/piotr-iohk/vendi'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  spec.files         = Dir['{bin,lib}/**/*', 'LICENSE.txt', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = ['vendi']
  spec.require_paths = %w[lib bin]

  spec.add_runtime_dependency 'cardano_wallet', '~> 0.3.28'
  spec.add_runtime_dependency 'docopt', '~> 0.6.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
