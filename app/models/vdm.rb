class Vdm < ActiveRecord::Base
  belongs_to :classes_planification
  has_many :vdm_changes
end
