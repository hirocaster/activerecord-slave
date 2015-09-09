describe ActiveRecord::Slave::DatabaseTasks do
  let(:args) do
    { replicaition: "task" }
  end

  after(:each) do
    ActiveRecord::Base.establish_connection(:test)
  end

  it "Create database" do
    ActiveRecord::Slave::DatabaseTasks.create_database args
    expect(ActiveRecord::Base.connection.execute("SHOW DATABASES").include? ["test_task"]).to be true
  end

  context "Created task replicaition database" do
    it "Drop database" do
      ActiveRecord::Slave::DatabaseTasks.drop_database args
      expect(ActiveRecord::Base.connection.execute("SHOW DATABASES").include? ["test_task"]).to be false
    end
  end
end
