class Subject < ActiveRecord::Base
  has_many :subject_planifications
  belongs_to :grade
  belongs_to :user
end
