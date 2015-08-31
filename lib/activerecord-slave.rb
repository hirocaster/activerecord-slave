require "active_record"

require "active_record/slave/replication_config"

module Activerecord
  module Slave
    # Your code goes here...
  end
end

ActiveSupport.on_load(:active_record) do
  require "active_record/slave/version"
  require "active_record/slave/model"

  ActiveRecord::Base.send(:include, ActiveRecord::Slave::Model)
end
