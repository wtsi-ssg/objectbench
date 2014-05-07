# -*- encoding : utf-8 -*-
class AddTagtoJobs < ActiveRecord::Migration
   def self.up
     add_column :jobs, :tag, :string
   end

   def self.down
     remove_column :jobs, :tag
   end
end
