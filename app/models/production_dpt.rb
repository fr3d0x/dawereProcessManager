class ProductionDpt < ActiveRecord::Base
  has_one :production_dpt_assignment
  belongs_to :vdm
end
