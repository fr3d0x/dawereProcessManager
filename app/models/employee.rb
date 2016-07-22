class Employee < ActiveRecord::Base
  has_one :user, :dependent => :destroy

  validates :firstName, presence: true
  validates :firstSurname, presence: true
  validates :personalId, presence: true
  validates :jobTittle, presence: true
  validates :email, presence: true
  validates :gender, presence: true
end
