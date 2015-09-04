require "pickup"

module ActiveRecord
  module Slave
    class ReplicationRouter
      def initialize(replication_config)
        fail "Not ActiveRecord::Slave::ReplicationConfig object." unless replication_config.is_a? ActiveRecord::Slave::ReplicationConfig
        @replication_config = replication_config
      end

      def master_connection_name
        @replication_config.master_connection_name
      end

      def slave_connection_name
        slaves = Pickup.new(@replication_config.slave_connection_names)
        slaves.pick(1)
      end
    end
  end
end
