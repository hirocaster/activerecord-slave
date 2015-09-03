base = { "adapter" => "mysql2", "encoding" => "utf8", "pool" => 5, "username" => "root", "password" => "msandbox", "host" => "127.0.0.1" }

ActiveRecord::Base.configurations = {
  "test_master"    => base.merge("database" => "test_slave", "port" => 21891),
  "test_slave_001" => base.merge("database" => "test_slave", "port" => 21892),
  "test_slave_002" => base.merge("database" => "test_slave", "port" => 21893),
  "test"           => base.merge("database" => "test", "port" => 3306, "password" => "")
}

ActiveRecord::Slave.configure do |config|
  config.define_replication(:user) do |replication|
    replication.register_master(:test_master)

    replication.register_slave(:test_slave_001, 70)
    replication.register_slave(:test_slave_002, 30)
  end
end

ActiveRecord::Base.establish_connection(:test)

class User < ActiveRecord::Base
  has_many :items

  include ActiveRecord::Slave::Model
  use_slave :user
end

class Item < ActiveRecord::Base
  belongs_to :user
end
