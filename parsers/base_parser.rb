# frozen_string_literal: true

require 'nokogiri'
require_relative '../loggers/simple_logger'

LOGGER = SimpleLogger

# Simple parser on nokogiri
class BaseParser
  def initialize(tags:, html:)
    @tags = tags
    @html = html
  end

  def call
    process_html
  end

  private

  attr_reader :tags, :html

  def process_html
    doc = Nokogiri::HTML(html)
    doc.search(tags).collect(&:content)
  rescue StandardError => e
    LOGGER.log_error(e)
  end
end
