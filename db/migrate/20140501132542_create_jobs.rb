class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :size
      t.integer :start
      t.integer :length
      t.string :reference_file
      t.string :md5sum
      t.string :operation
      t.string :system
      t.timestamp :start_time
      t.timestamp :end_time

      t.timestamps
    end
  end
end
