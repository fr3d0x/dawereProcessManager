class ClassesPlanification < ActiveRecord::Base
  belongs_to :subject_planification
  has_many :vdms
end
