class ClassesPlanification < ActiveRecord::Base
  belong_to :subject_planification
  has_many :vdms
end
