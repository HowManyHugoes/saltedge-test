# frozen_string_literal: true

require_relative 'http_clients/base_http_client'
require_relative 'workers/base_http_worker'
require_relative 'caches/ram_cache'
require_relative 'parsers/base_parser'

# Main scraper. Accepts array of urls, return array of hashes with html in {url: 'foo', html: 'bar'} format
# Additional option - html_tags. If received, scraper will return contant of received tags searching instead of
# a whole html. By default it uses Nokogiri .search method under the hood, so you can provide tags in a Nokogiri format
class HttpScraper
  DEFAULT_THREAD_POOL_SIZE = 10

  # rubocop :disable Metrics/ParameterLists
  def initialize(
    http_worker_class: BaseHttpWorker,
    pool_size: DEFAULT_THREAD_POOL_SIZE,
    cache: RamCache,
    parser: BaseParser,
    html_tags: nil,
    urls: []
  )

    @http_worker_class = http_worker_class
    @urls_queue = create_queue(urls) if urls
    @pool_size = pool_size
    @cache = cache
    @html_tags = html_tags
    @parser = parser
  end

  # rubocop :enable Metrics/ParameterLists

  def call
    process
  end

  private

  attr_reader :http_worker_class, :pool_size, :urls_queue, :cache, :html_tags, :parser

  def process
    threads = pool_size.times.collect do
      run_new_thread
    end
    threads.map(&:value).reject(&:empty?).flatten
  end

  def run_new_thread
    Thread.new do
      thread_results = []
      while (url = urls_queue.pop(true))
        next unless (html = get_html(url))

        cache_result(url, html)
        thread_results << { url: url, html: parse_for_elements(html) }
      end
    rescue ThreadError
      thread_results
    end
  end

  def get_html(url)
    get_result_from_cache(url) || run_worker(url)
  end

  def get_result_from_cache(key)
    cache.get(key)
  end

  def cache_result(key, value, force: false)
    return if !cache.contains?(key) && !force

    cache.set(key, value)
  end

  def create_queue(urls)
    q = Queue.new
    urls.each { |url| q << url }
    q
  end

  def parse_for_elements(html)
    return html unless html_tags

    parser.new(html: html, tags: html_tags).call
  end

  def run_worker(url)
    http_worker_class.new(url).call
  end
end
