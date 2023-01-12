# frozen_string_literal: true

require 'digest'

# Stores values in a RAM while project is running
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

    private

    def storage
      @storage ||= {}
    end
  end
end
