require 'redis'
require 'connection_pool'
require 'active_model'
require 'active_support/all'
require 'yaml'
require 'msgpack'

require 'modis/version'
require 'modis/configuration'
require 'modis/attribute'
require 'modis/errors'
require 'modis/persistence'
require 'modis/transaction'
require 'modis/finder'
require 'modis/index'
require 'modis/model'

module Modis
  @mutex = Mutex.new

  class << self
    attr_accessor :connection_pool, :redis_options, :connection_pool_size,
                  :connection_pool_timeout
  end

  self.redis_options = { driver: :hiredis }
  self.connection_pool_size = 10000
  self.connection_pool_timeout = 300

  def self.connection_pool
    return @connection_pool if @connection_pool
    @mutex.synchronize do
      options = { size: connection_pool_size, timeout: connection_pool_timeout }
      @connection_pool = ConnectionPool.new(options) { Redis.new(redis_options) }
    end
  end

  def self.with_connection
    connection_pool.with { |connection| yield(connection) }
  end
end
