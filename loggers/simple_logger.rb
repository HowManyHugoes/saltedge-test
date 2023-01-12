# frozen_string_literal: true

require 'json'

# Simple file logger
class SimpleLogger
  DEFAULT_PATH = './logs/error.log'

  def self.log_error(error)
    File.write(DEFAULT_PATH, JSON.dump({ timestamp: Time.now.to_s, error: error.to_s }), mode: 'a')
  end
end
