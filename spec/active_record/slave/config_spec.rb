describe ActiveRecord::Slave::Config do
  let!(:config) do
    config = ActiveRecord::Slave::Config.new
    config.define_replication(:test) do |replication|
      replication.register_master :test_master
      replication.register_slave :test_slave_001, 70
      replication.register_slave :test_slave_002, 30
    end
    config
  end

  describe "#fetch_replication_config" do
    it "returns :test replication config" do
      expect(config.fetch_replication_config :test).to be_a ActiveRecord::Slave::ReplicationConfig
    end
  end
end
