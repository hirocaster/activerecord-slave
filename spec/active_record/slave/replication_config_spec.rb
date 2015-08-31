describe ActiveRecord::Slave::ReplicationConfig do
  let!(:replication_config) do
    config = ActiveRecord::Slave::ReplicationConfig.new :test_replication

    config.register_master :test_master

    config.register_slave :test_slave_001, 70
    config.register_slave :test_slave_002, 30

    config
  end

  context "not setup config for ReplicationConfig object" do
    context "#validate_config!" do
      let!(:not_setup_replication_config) { ActiveRecord::Slave::ReplicationConfig.new :test_replication }

      it "returns raise, nothing register master connection" do
        expect { not_setup_replication_config.validate_config! }.to raise_error "Nothing register master connection."
      end

      it "returns nil, config is valid" do
        expect(replication_config.validate_config!).to be nil
      end
    end
  end

  context "#name" do
    it "returns replication name" do
      expect(replication_config.name).to eq :test_replication
    end
  end

  context "#master_connection_name" do
    it "returns master database connection name" do
      expect(replication_config.master_connection_name).to eq :test_master
    end
  end

  context "#slave_connection_names" do
    it "returns slave database connection names" do
      expect(replication_config.slave_connection_names).to be_a Hash
      expect(replication_config.slave_connection_names).to include test_slave_001: 70
      expect(replication_config.slave_connection_names).to include test_slave_002: 30
    end
  end
end
