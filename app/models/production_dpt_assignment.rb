class ProductionDptAssignment < ActiveRecord::Base
  belongs_to :production_dpt
  belongs_to :user
end
