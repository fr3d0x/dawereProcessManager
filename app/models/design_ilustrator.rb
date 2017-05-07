class DesignIlustrator < ActiveRecord::Base
  belongs_to :design_assignment
  mount_uploader :file, DesignIllustratorUploader

end
