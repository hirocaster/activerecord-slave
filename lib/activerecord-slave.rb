require "active_support/lazy_load_hooks"

require "active_record"

require "active_record/slave/version"
require "active_record/slave/config"
require "active_record/slave/replication_config"
require "active_record/slave/replication_router"
require "active_record/slave/model"

module ActiveRecord
  module Slave
    class << self
      def config
        @config ||= Config.new
      end

      def configure(&block)
        config.instance_eval(&block)
      end
    end
  end
end
