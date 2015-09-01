describe ActiveRecord::Slave::ReplicationRouter do
  let!(:replication_config) do
    config = ActiveRecord::Slave::Config.new
    config.define_replication(:test) do |replication|
      replication.register_master :test_master
      replication.register_slave :test_slave_001, 70
      replication.register_slave :test_slave_002, 30
    end
    config.fetch_replication_config :test
  end

  let!(:replication_router) do
    ActiveRecord::Slave::ReplicationRouter.new replication_config
  end

  describe "#new" do
    it "Make instance object" do
      expect(ActiveRecord::Slave::ReplicationRouter.new replication_config).to be_a ActiveRecord::Slave::ReplicationRouter
    end

    it "Raise error" do
      expect { ActiveRecord::Slave::ReplicationRouter.new "test" }.to raise_error "Not ActiveRecord::Slave::ReplicationConfig object."
    end
  end

  describe "#master_connection_name" do
    it "returns master database conneciton name" do
      expect(replication_router.master_connection_name).to eq :test_master
    end
  end

  describe "#slave_connection_name" do
    it "returns slave database conneciton name, by wait lottery confidence 99%" do
      slave_connection_names = 10000.times.map { replication_router.slave_connection_name }
      expect(slave_connection_names.count(:test_slave_001)).to be_between 7000-60, 7000+60
      expect(slave_connection_names.count(:test_slave_002)).to be_between 3000-60, 3000+60
      expect(slave_connection_names.count(:test_slave_001)).to be_between 7000 - 60, 7000 + 60
      expect(slave_connection_names.count(:test_slave_002)).to be_between 3000 - 60, 3000 + 60
      expect(slave_connection_names).to include :test_slave_001
      expect(slave_connection_names).to include :test_slave_002
    end
  end
end
