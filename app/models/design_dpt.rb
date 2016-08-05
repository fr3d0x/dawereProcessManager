class DesignDpt < ActiveRecord::Base
  has_one :design_assignment
  belongs_to :vdm
end
