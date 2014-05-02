class CreateNullConfigs < ActiveRecord::Migration
  def change
    create_table :null_configs do |t|
      t.integer :read_speed ,          limit: 8
      t.integer :write_speed ,         limit: 8

      t.timestamps
    end
  end
end
