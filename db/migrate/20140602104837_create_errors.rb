class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.text :exception
      t.text :backtrace
      t.string :worker
      t.text :error
      t.string :reported_at
      t.references :job, index: true

      t.timestamps
    end
  end
end
