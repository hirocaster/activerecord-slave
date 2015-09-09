namespace :active_record do
  namespace :slave do
    desc "Create database for replicaition master"
    task :db_create, %i(replicaition) => %i(environment) do |_, args|
      ActiveRecord::Slave::DatabaseTasks.create_database args
    end

    desc "Drop database for replicaition master"
    task :db_drop, %i(replicaition) => %i(environment) do |_, args|
      ActiveRecord::Slave::DatabaseTasks.drop_database args
    end
  end
end
