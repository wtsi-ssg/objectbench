class AddJobReferenceToError < ActiveRecord::Migration
  def change
    add_reference :jobs, :error, index: true

  end
end
