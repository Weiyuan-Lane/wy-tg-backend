class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.integer :object_id, :null => false
      t.string :object_type, :null => false
      t.timestamp :timestamp, :null => false
      t.json :object_changes, :null => false

      t.timestamps
    end
  end
end
