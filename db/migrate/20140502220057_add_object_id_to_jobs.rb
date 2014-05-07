# -*- encoding : utf-8 -*-
class AddObjectIdToJobs < ActiveRecord::Migration
   def self.down
         remove_column :jobs, :object_id
   end

   def self.up
         add_column :jobs, :object_id  , :string
   end

end
