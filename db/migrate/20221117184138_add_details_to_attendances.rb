class AddDetailsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_at, :datetime
    add_column :attendances, :overtime_content, :string
    add_column :attendances, :overtime_approval_status, :string
    add_column :attendances, :overtime_instructor, :string
    add_column :attendances, :overtime_chg_permission, :boolean, default: false
  end
end
