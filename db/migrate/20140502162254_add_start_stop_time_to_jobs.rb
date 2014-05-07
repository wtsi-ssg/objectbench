# -*- encoding : utf-8 -*-
class AddStartStopTimeToJobs < ActiveRecord::Migration
   def self.up
          add_column :jobs, :work_starts, :datetime
          add_column :jobs, :work_ends  , :datetime
   end

   def self.down
           remove_column :jobs, :work_starts
           remove_column :jobs, :work_ends
   end

end
