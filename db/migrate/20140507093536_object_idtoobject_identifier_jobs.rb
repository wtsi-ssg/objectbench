class ObjectIdtoobjectIdentifierJobs < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.rename :object_id, :object_identifier
    end
  end

  def self.down
    change_table :jobs do |t| 
      t.rename :object_identifier, :object_id
    end
  end
end
