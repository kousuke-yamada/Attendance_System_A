class AddDetailToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructor, :string
    add_column :attendances, :chg_started_at, :datetime
    add_column :attendances, :chg_finished_at, :datetime
    add_column :attendances, :approval_date, :date
    add_column :attendances, :first_started_at, :datetime
    add_column :attendances, :first_finished_at, :datetime
    add_column :attendances, :approval_status, :string
  end
end
