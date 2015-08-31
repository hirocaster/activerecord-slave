require "active_record"

require "active_record/slave/config"
require "active_record/slave/replication_config"

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

ActiveSupport.on_load(:active_record) do
  require "active_record/slave/version"
  require "active_record/slave/model"

  ActiveRecord::Base.send(:include, ActiveRecord::Slave::Model)
end
