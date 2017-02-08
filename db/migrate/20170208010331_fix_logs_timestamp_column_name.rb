class FixLogsTimestampColumnName < ActiveRecord::Migration[5.0]
  def change
    change_table :logs do |t|
      t.rename :timestamp, :log_timestamp
    end
  end
end
