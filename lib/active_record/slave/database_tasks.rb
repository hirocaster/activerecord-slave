module ActiveRecord
  module Slave
    module DatabaseTasks
      extend self

      def create_database(args)
        configuration = database_configuration args
        ActiveRecord::Tasks::DatabaseTasks.create configuration
      end

      def drop_database(args)
        configuration = database_configuration args
        ActiveRecord::Tasks::DatabaseTasks.drop configuration
      end

      def database_configuration(args)
        replication_name = args[:replicaition]
        replication_config = fetch_replication_config replication_name.to_sym
        connection_name = replication_config.master_connection_name
        ActiveRecord::Base.configurations[connection_name.to_s]
      end

      def fetch_replication_config(replication_name)
        ActiveRecord::Slave.config.fetch_replication_config replication_name
      rescue KeyError
        raise "Not exist #{replication_name} replicaition."
      end
    end
  end
end
