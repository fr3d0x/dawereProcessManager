class Vdm < ActiveRecord::Base
  belongs_to :classes_planification
  has_many :vdm_changes
  has_one :production_dpt
  has_one :design_dpt
  has_one :product_management
end
