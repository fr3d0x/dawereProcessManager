class SubjectPlanification < ActiveRecord::Base
  belongs_to :subject
  belongs_to :teacher
  has_many :classes_planifications

end
