class RenameBasicTimeColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :basic_time, :basic_work_time
  end
end
