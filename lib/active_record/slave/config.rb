module ActiveRecord
  module Slave
    class Config
      def initialize
        @replication_configs = {}
      end

      def define_replication(replication_name, &block)
        replication_config = ReplicationConfig.new(replication_name)
        replication_config.instance_eval(&block)
        replication_config.validate_config!
        @replication_configs[replication_name] = replication_config
      end

      def fetch_replication_config(replication_name)
        @replication_configs.fetch replication_name
      end
    end
  end
end
