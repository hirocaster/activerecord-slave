base = { "adapter" => "mysql2", "encoding" => "utf8", "pool" => 5, "username" => "root", "password" => "msandbox", "host" => "127.0.0.1" }

ActiveRecord::Base.configurations = {
  "test_master"    => base.merge("database" => "test_slave", "port" => 21891),
  "test_slave_001" => base.merge("database" => "test_slave", "port" => 21892),
  "test_slave_002" => base.merge("database" => "test_slave", "port" => 21893),
  "test"           => base.merge("database" => "test", "port" => 3306, "password" => ""),

  "test_task_master" => base.merge("database" => "test_task", "port" => 21891),
  "test_task_slave_001"   => base.merge("database" => "test_task", "port" => 21892),
  "test_task_slave_002"   => base.merge("database" => "test_task", "port" => 21893)
}

ActiveRecord::Slave.configure do |config|
  config.define_replication(:user) do |replication|
    replication.register_master(:test_master)

    replication.register_slave(:test_slave_001, 70)
    replication.register_slave(:test_slave_002, 30)
  end

  config.define_replication(:task) do |replication|
    replication.register_master(:test_task_master)

    replication.register_slave(:test_task_slave_001, 1)
    replication.register_slave(:test_task_slave_002, 1)
  end
end

ActiveRecord::Base.establish_connection(:test)

class User < ActiveRecord::Base
  has_many :items
  has_many :skills

  include ActiveRecord::Slave::Model
  use_slave :user
end

class Item < ActiveRecord::Base
  belongs_to :user
end

class Skill < ActiveRecord::Base
  belongs_to :user

  include ActiveRecord::Slave::Model
  use_slave :user
end
