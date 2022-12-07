class RenameWorkTimeColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :work_time, :designated_work_start_time
  end
end
