describe ActiveRecord::Slave::Model do
  it "connect to master" do
    expect(User.connection.pool.spec.config[:port]).to eq 21891
  end

  it "connect to slaves" do
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

  describe "Assosiations" do
    let(:user) { User.create name: "alice" }
    let(:item) { Item.create name: "foo", count: 1, user: user }
    let(:skill) { Skill.create name: "bar", user: user }

    it "returns user object, belongs_to" do
      expect(item.user).to be_a User
      expect(item.user.id).to eq user.id
    end

    context "Add has_many object" do
      it "connect to default database" do
        expect { item }.to change { user.items.count }.from(0).to(1)
        expect { Item.create name: "bar", count: 1, user: user }.to change { user.items.count }.from(1).to(2)
        expect(Item.find(item.id).user).to eq user
        expect(Item.connection.pool.spec.config[:port]).to eq 3306
      end

      it "connect to replication databases" do
        expect { skill }.to change { user.skills.count }.from(0).to(1)
        expect { Skill.create name: "foobar", user: user }.to change { user.skills.count }.from(1).to(2)
        expect(Skill.find(skill.id).user).to eq user
        expect(Skill.slave_for.find(skill.id).user).to eq user
        expect(Skill.connection.pool.spec.config[:port]).to eq 21891
        expect(Skill.slave_for.connection.pool.spec.config[:port]).to eq(21892) | eq(21893)
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
