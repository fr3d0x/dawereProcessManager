class DesignElement < ActiveRecord::Base
  belongs_to :design_assignment
  mount_uploader :file, DesignElementsUploader
end
