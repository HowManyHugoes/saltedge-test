# frozen_string_literal: true

require 'digest'

class RamCache
  class << self
    def set(key, content)
      storage[key] = content
    end

    def get(key)
      storage[key]
    end

    def contains?(key)
      storage.key?(key)
    end

    def get_all
      storage.to_a
    end

    private

    def storage
      @storage ||= {}
    end
  end
end
