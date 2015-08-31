module ActiveRecord
  module Slave
    class ReplicationConfig
      attr_reader :name, :master_connection_name

      def initialize(replication_name)
        @name = replication_name
      end

      def validate_config!
        fail "Nothing register master connection." unless @master_connection_name
      end

      def register_master(connection_name)
        @master_connection_name = connection_name
      end

      def register_slave(connection_name, weigh)
        @slave_connection_registory ||= {}
        @slave_connection_registory.store connection_name, weigh
      end

      def slave_connection_names
        @slave_connection_registory
      end
    end
  end
end
