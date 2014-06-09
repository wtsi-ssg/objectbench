class AddMultipleJobTypes < ActiveRecord::Migration
  def change
    add_column :jobs, :type , :string
  end
end
