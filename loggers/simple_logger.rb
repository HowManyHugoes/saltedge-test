# frozen_string_literal: true

class SimpleLogger
  DEFAULT_PATH = './log.txt'

  def self.log_error(error)
    File.write(DEFAULT_PATH, JSON.dump({ timestamp: Time.now.to_s, error: error.to_s }), mode: 'a')
  end
end
