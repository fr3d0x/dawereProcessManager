class DesignJpg < ActiveRecord::Base
  belongs_to :design_assignment
  mount_uploader :file, DesignJpgUploader
end
