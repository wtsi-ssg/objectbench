class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :size
      t.integer :length
      t.string :reference_file
      t.string :md5sum
      t.string :type
      t.string :operation

      t.timestamps
    end
  end
end
