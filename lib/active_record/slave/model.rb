require "active_support/concern"

module ActiveRecord
  module Slave
    module Model
      extend ActiveSupport::Concern

      included do |model|
        private_class_method :generate_class
        model.singleton_class.class_eval do
          include SingletonClassMethods
          alias_method_chain :connection, :slave
        end
      end

      module SingletonClassMethods
        def connection_with_slave
          if @slave_mode
            @class_repository.fetch(@replication_router.slave_connection_name).connection
          elsif @enable_slave
            @class_repository.fetch(@replication_router.master_connection_name).connection
          else
            connection_without_slave
          end
        end
      end

      module ClassMethods
        def use_slave(replication_name)
          @enable_slave = true
          @slave_mode = false

          replication_config     = ActiveRecord::Slave.config.fetch_replication_config replication_name
          @replication_router    = ActiveRecord::Slave::ReplicationRouter.new replication_config

          @class_repository = {}
          base_class = self

          connection_name = replication_config.master_connection_name
          @class_repository[connection_name] = generate_class(base_class, connection_name)

          replication_config.slave_connection_names.keys.each do |slave_connection_name|
            @class_repository[slave_connection_name] = generate_class(base_class, slave_connection_name)
          end
        end

        def slave_for
          @class_repository.fetch(@replication_router.slave_connection_name)
        end

        def generate_class(base_class, connection_name)
          model = Class.new(base_class) do
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.name
                      "#{base_class.name}::#{connection_name}"
                    end
                  RUBY
          end
          model.class_eval { establish_connection(connection_name) }
          model
        end
      end
    end
  end
end
