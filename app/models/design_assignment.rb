class DesignAssignment < ActiveRecord::Base
  belongs_to :design_dpt
  belongs_to :user
end
