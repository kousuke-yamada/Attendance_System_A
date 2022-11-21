class MonthlyAttendance < ApplicationRecord
  belongs_to :user

  validates :month, presence: true
  validates :year, presence: true
end
