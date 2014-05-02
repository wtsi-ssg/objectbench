class Deletemd5sumToJobs < ActiveRecord::Migration
  # Yes this deletes data....
   def self.up
         remove_column :jobs, :md5sum
   end

   def self.down
         add_column :jobs, :md5sum  , :string
   end
end
