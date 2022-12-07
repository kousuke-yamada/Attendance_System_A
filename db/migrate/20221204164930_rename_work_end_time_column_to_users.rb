class RenameWorkEndTimeColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :work_end_time, :designated_work_end_time
  end
end
