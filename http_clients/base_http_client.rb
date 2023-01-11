# frozen_string_literal: true

require 'httparty'

# Simple client on httparty
class BaseHttpClient

  def initialize(url)
    @url = url
  end

  def call
    body
  end

  private

  attr_reader :url

  def body
    response.body
  end

  def response
    HTTParty.get(url).response
  end

end
