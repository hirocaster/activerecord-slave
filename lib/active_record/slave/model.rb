require "active_support/concern"

module ActiveRecord
  module Slave
    module Model
      extend ActiveSupport::Concern

      included do
        private_class_method :define_slave_class
      end

      module ClassMethods
        def use_slave(replication_name)
          replication_config  = ActiveRecord::Slave.config.fetch_replication_config replication_name
          @replication_router = ActiveRecord::Slave::ReplicationRouter.new replication_config

          establish_connection replication_config.master_connection_name

          @slave_class_repository = {}
          base_class = self
          replication_config.slave_connection_names.keys.each do |connection_name|
            @slave_class_repository[connection_name] = define_slave_class base_class, connection_name
          end
        end

        def slave_for
          @slave_class_repository.fetch @replication_router.slave_connection_name
        end

        def define_slave_class(base_class, connection_name)
          model = Class.new(base_class) do
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.name
                      "#{base_class.name}::Slave::#{connection_name}"
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
