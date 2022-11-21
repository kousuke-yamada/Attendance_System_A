class CreateMonthlyAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_attendances do |t|
      t.datetime :month
      t.string :instructor
      t.string :approval_status
      t.boolean :chg_permission, default: false

      t.timestamps
    end
  end
end
