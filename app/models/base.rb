class Base < ApplicationRecord
  validates :baseno,   presence: true
  validates :basename, presence: true
  validates :basekind, presence: true
end
