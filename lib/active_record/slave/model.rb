require "active_support/concern"

module ActiveRecord
  module Slave
    module Model
      extend ActiveSupport::Concern

      included do |model|
        model.singleton_class.class_eval do
          include SingletonClassMethods
          alias_method_chain :connection, :slave
        end
      end

      module SingletonClassMethods
        def connection_with_slave
          if @enable_slave
            @slave_model.connection
          elsif @master_model
            @master_model.connection
          else
            connection_without_slave
          end
        end
      end

      module ClassMethods
        def use_slave
          base_class = self
          @enable_slave = false

          connection_name = :test_slave_002
          model = Class.new(base_class) do
                    self.table_name = base_class.table_name
                    module_eval <<-RUBY, __FILE__, __LINE__ + 1
                      def self.name
                        "#{base_class.name}::Slave"
                      end
                    RUBY
                  end
          model.class_eval { establish_connection(connection_name) }
          @slave_model = model

          connection_name = :test_master
          model = Class.new(base_class) do
                    self.table_name = base_class.table_name
                    module_eval <<-RUBY, __FILE__, __LINE__ + 1
                      def self.name
                        "#{base_class.name}::Master"
                      end
                    RUBY
                  end
          model.class_eval { establish_connection(connection_name) }
          @master_model = model
        end

        def on_slave(&block)
          @enable_slave = true
          result = yield
          @enable_slave = false
          result
        end
      end
    end
  end
end
