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
      "#{quantity.to_f / 1_000_000} ₳"
    end
  end
end
