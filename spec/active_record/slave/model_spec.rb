describe ActiveRecord::Slave::Model do
  it "connect to master" do
    expect(User.connection.pool.spec.config[:port]).to eq 21891
  end

  it "connect to slaves", retry: 3 do
    slave_ports = 10.times.map { User.slave_for.connection.pool.spec.config[:port] }.uniq
    expect(slave_ports.count).to eq 2
    expect(slave_ports).to include 21892
    expect(slave_ports).to include 21893
  end

  it "connect to default" do
    expect(Item.connection.pool.spec.config[:port]).to eq 3306
  end

  describe "Write to master, Read from slave" do
    it "returns user object from slave database" do
      user_from_master = User.create name: "alice"

      user_from_slave  = User.slave_for.find user_from_master.id

      expect(user_from_master.id).to eq user_from_slave.id
      expect(user_from_master.name).to eq user_from_slave.name
    end
  end

  describe "multi thread" do
    before do
      Parallel.each((0..99).to_a, :in_threads => 8) do |dummy|
        User.connection_pool.with_connection do
          User.create name: "test#{dummy}"
        end
      end
    end

    it "returns writed models" do
      Parallel.each((0..14).to_a, :in_threads => 8) do |dummy|
        User.slave_for.connection_pool.with_connection do
          expect(User.slave_for.all.count).to eq 100
        end
      end
    end
  end

  describe "Assosiations" do
    let(:user) { User.create name: "alice" }

    context "has_many object" do
      context "in default database" do
        let(:item) { Item.create name: "foo", count: 1, user: user }

        it "returns user object, belongs_to" do
          expect(item.user).to be_a User
          expect(item.user.id).to eq user.id
        end

        describe "model connect to default database" do
          it "returns has_many objects" do
            expect { item }.to change { user.items.count }.from(0).to(1)
            expect { Item.create name: "bar", count: 1, user: user }.to change { user.items.count }.from(1).to(2)
          end

          it "returns replication model object" do
            expect(Item.find(item.id).user).to eq user
          end

          it "returns default database service port" do
            expect(Item.connection.pool.spec.config[:port]).to eq 3306
          end
        end
      end

      context "in replication database" do
        let(:skill) { Skill.create name: "bar", user: user }

        it "returns user object, belongs_to" do
          expect(skill.user).to be_a User
          expect(skill.user.id).to eq user.id
        end

        describe "model connect to raplication databases" do
          it "returns has_many objects" do
            expect { skill }.to change { user.skills.count }.from(0).to(1)
            expect { Skill.create name: "foobar", user: user }.to change { user.skills.count }.from(1).to(2)
            expect(user.skills.count).to eq Skill.slave_for.where(user_id: user.id).count
          end

          it "returns other model object from master" do
            expect(Skill.find(skill.id).user).to eq user
          end

          it "returns other model object from slaves" do
            expect(Skill.slave_for.find(skill.id).user).to eq user
          end

          it "returns master database service port" do
            expect(Skill.connection.pool.spec.config[:port]).to eq 21891
          end

          it "returns slave database service port" do
            expect(Skill.slave_for.connection.pool.spec.config[:port]).to eq(21892) | eq(21893)
          end
        end
      end
    end

    context "Enable DatabaseRewinder, delete records at each after specs" do
      it "No records in DataBases" do
        expect(User.all.count).to eq 0
        expect(Item.all.count).to eq 0
        expect(Skill.all.count).to eq 0
      end
    end
  end
end
