class DesignDpt < ActiveRecord::Base
  has_one :design_assigment
  belongs_to :vdm
end
