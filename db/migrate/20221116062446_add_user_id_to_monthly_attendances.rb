class AddUserIdToMonthlyAttendances < ActiveRecord::Migration[5.1]
  def change
    add_reference :monthly_attendances, :user, foreign_key: true
  end
end
