# Activerecord::Slave

[![Build Status](https://travis-ci.org/hirocaster/activerecord-slave.svg?branch=master)](https://travis-ci.org/hirocaster/activerecord-slave) [![Coverage Status](https://coveralls.io/repos/hirocaster/activerecord-slave/badge.svg?branch=master&service=github)](https://coveralls.io/github/hirocaster/activerecord-slave?branch=master) [![Code Climate](https://codeclimate.com/github/hirocaster/activerecord-slave/badges/gpa.svg)](https://codeclimate.com/github/hirocaster/activerecord-slave) [![Dependency Status](https://gemnasium.com/hirocaster/activerecord-slave.svg)](https://gemnasium.com/hirocaster/activerecord-slave)

ActiveRecord for MySQL Replication databases(master/slave).

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-slave'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-slave

## Usage

Add database connections to your application's config/database.yml:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  database: user
  username: root
  password:
  host: localhost

user_master:
  <<: *default
  host: master.db.example.com

user_slave_001:
  <<: *default
  host: slave_001.db.example.com

user_slave_002:
<<: *default
  host: slave_002.db.example.com
  ```

Add this example, your application's config/initializers/active_record_slave.rb:

```ruby
ActiveRecord::Slave.configure do |config|
  config.define_replication(:user) do |replication| # replication name
    replication.register_master(:user_master)       # master connection

    replication.register_slave(:user_slave_001, 70) # slave connection, weight
    replication.register_slave(:user_slave_002, 30)
  end
end
```

### Model

app/model/user.rb

```ruby
class User < ActiveRecord::Base
  has_many :items
  include ActiveRecord::Slave::Model
  use_slave :user # replicaition name
end

class Item < ActiveRecord::Base
  belongs_to :user
  include ActiveRecord::Slave::Model
  use_slave :user # replicaition name
end
```

Query for master database.

```ruby
User.all
User.find(1)
User.where(name: "foobar")
```

Query for slave databases.

distrebute(load-balance) connection by configured weight settings.

```ruby
User.slave_for.all
User.slave_for.find(1)
User.slave_for.where(name: "foobar")
```

Association case. If select from slave, should use #slave_for. Not use assosiaion daynamic methods.

```ruby
User.find(1).items # items from master database

user = User.find(1)
Item.slave_for(user_id: user.id) # items from slave databases
```

## Contributing

1. Fork it ( http://github.com/hirocaster/activerecord-slave/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
