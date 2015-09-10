require "rake"

describe "Tasks :active_record:slave" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "./../lib/tasks/activerecord-slave"
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @rake[task].reenable
  end

  after(:each) do
    ActiveRecord::Base.establish_connection(:test)
  end

  describe ".db_create" do
    let(:task) { "active_record:slave:db_create" }
    let(:replicaition) { "task" }
    let(:database) { ["test_task"] }

    it "Create replicaition database by task" do
      @rake[task].invoke(replicaition)
      expect(ActiveRecord::Base.connection.execute("SHOW DATABASES").include? database).to be true
    end

    it "return raise, not exist replicaition" do
      expect { @rake[task].invoke("dummy") }.to raise_error RuntimeError, "Not exist dummy replicaition."
    end

    context "Created replicaition database" do
      describe ".db_drop" do
        let(:task) { "active_record:slave:db_drop" }

        it "Drop replicaition database by task" do
          @rake[task].invoke(replicaition)
          expect(ActiveRecord::Base.connection.execute("SHOW DATABASES").include? database).to be false
        end

        it "return raise, not exist replicaition" do
          expect { @rake[task].invoke("dummy") }.to raise_error RuntimeError, "Not exist dummy replicaition."
        end
      end
    end
  end
end
