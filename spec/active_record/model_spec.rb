describe ActiveRecord::Slave::Model do
  it "connect to master" do
    expect(User.connection.pool.spec.config[:port]).to eq 21891
  end

  it "connect to slave" do
    User.on_slave do
      expect(User.connection.pool.spec.config[:port]).to eq 21893
    end
  end

  it "connect to default" do
    expect(Item.connection.pool.spec.config[:port]).to eq 3306
  end
end
