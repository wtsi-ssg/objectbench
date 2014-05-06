class ChangeTimeToStringJob < ActiveRecord::Migration
  def self.up
    remove_column :jobs, :work_starts
    remove_column :jobs, :work_ends
    add_column :jobs, :work_starts, :string
    add_column :jobs, :work_ends, :string
  end

  def self.down
    remove_column :jobs, :work_starts
    remove_column :jobs, :work_ends
    add_column :jobs, :work_starts, :float
    add_column :jobs, :work_ends  , :float
  end
end
