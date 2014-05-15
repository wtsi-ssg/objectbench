# -*- encoding : utf-8 -*-
class ChangetimestostringToJobs < ActiveRecord::Migration
  # Yes this deletes data....
   def self.up
          remove_column :jobs, :work_starts
          remove_column :jobs, :work_ends
          add_column :jobs, :work_starts, :float
          add_column :jobs, :work_ends  , :float
   end

   def self.down
           remove_column :jobs, :work_starts
           remove_column :jobs, :work_ends
           add_column :jobs, :work_starts, :datetime
           add_column :jobs, :work_ends  , :datetime
   end

end
