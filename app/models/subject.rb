class Subject < ActiveRecord::Base
  has_many :subject_planifications
  belongs_to :grade
end
