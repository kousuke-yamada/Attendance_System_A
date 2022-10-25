class AddDetailsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer
    add_column :users, :uid, :string
    add_column :users, :work_end_time, :datetime,  default: Time.current.change(hour:7,min:30,sec:0)
    add_column :users, :superior, :boolean, default: false
  end
end
