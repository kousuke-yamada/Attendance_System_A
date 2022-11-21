class AddYearToMonthlyAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :monthly_attendances, :year, :string
  end
end
