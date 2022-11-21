class ChangeDateMonthToMonthlyAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :monthly_attendances, :month, :string
  end
end
