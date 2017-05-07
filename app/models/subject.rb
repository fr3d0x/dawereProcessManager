class Subject < ActiveRecord::Base
  has_one :subject_planification
  belongs_to :grade
  belongs_to :user
end
