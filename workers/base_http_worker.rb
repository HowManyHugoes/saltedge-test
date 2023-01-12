# frozen_string_literal: true

require_relative '../http_clients/base_http_client'
require_relative '../loggers/simple_logger'

# Simple worker
class BaseHttpWorker
  FAILS_ALLOWED_DEFAULT = 5
  DEFAULT_TIMEOUT = 0.15

  def initialize(url, client_class = BaseHttpClient, fails_allowed = FAILS_ALLOWED_DEFAULT, timeout = DEFAULT_TIMEOUT)
    @client = client_class.new(url)
    @fails_allowed = fails_allowed
    @timeout = timeout
    @counter = 0
  end

  def call
    process
  end

  private

  attr_reader :client, :fails_allowed, :counter, :timeout

  def process
    return if counter_exceeded?

    client.call
  rescue StandardError => e
    SimpleLogger.log_error(e)
    increment_counter
  end

  def counter_exceeded?
    counter > fails_allowed
  end

  def increment_counter
    @counter += 1
  end

  def wait_for_timeout
    sleep(2)
  end
end
