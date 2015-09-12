module ActiveRecord
  module Slave
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path("../../../tasks/activerecord-slave.rake", __FILE__)
      end
    end
  end
end
