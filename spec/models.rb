base = { "adapter" => "mysql2", "encoding" => "utf8", "pool" => 5, "username" => "root", "password" => "msandbox", "host" => "127.0.0.1" }

ActiveRecord::Base.configurations = {
  "test_master"    => base.merge("database" => "test_slave", "port" => 21891),
  "test_slave_001" => base.merge("database" => "test_slave", "port" => 21892),
  "test_slave_002" => base.merge("database" => "test_slave", "port" => 21893),
  "test"           => base.merge("database" => "test", "port" => 3306, "password" => "")
}

ActiveRecord::Base.establish_connection(:test)

class User < ActiveRecord::Base
  has_many :items

  use_slave
end

class Item < ActiveRecord::Base
  belongs_to :user
end
