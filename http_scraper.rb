# frozen_string_literal: true

require_relative 'http_clients/base_http_client'
require_relative 'workers/base_http_worker'
require_relative 'caches/ram_cache'

# Main scraper. Accepts array of urls, return array of hashes with html in {url: 'foo', html: 'bar'} format
class HttpScraper
  DEFAULT_THREAD_POOL_SIZE = 10

  def initialize(http_worker_class = BaseHttpWorker, pool_size = DEFAULT_THREAD_POOL_SIZE, cache = RamCache, urls)
    @http_worker_class = http_worker_class
    @urls_queue = create_queue(urls)
    @pool_size = pool_size
    @cache = cache
  end

  def call
    process
  end

  private

  attr_reader :http_worker_class, :pool_size, :urls_queue, :cache

  def process
    threads = pool_size.times.collect do
      Thread.new do
        thread_results = []
        begin
          while (url = urls_queue.pop(true))
            html = get_result_from_cache(url) || run_worker(url)
            next unless html

            cache_result(url, html)
            thread_results << { url: url, html: html }
          end
        rescue ThreadError
          thread_results
        end
      end
    end
    threads.map(&:value).reject(&:empty?).flatten
  end

  def get_result_from_cache(key)
    cache.get(key)
  end

  def cache_result(key, value, force = false)
    return if !cache.contains?(key) && !force

    cache.set(key, value)
  end

  def create_queue(urls)
    q = Queue.new
    urls.each { |url| q << url }
    q
  end

  def run_worker(url)
    http_worker_class.new(url).call
  end
end
