class MasterPlane < ActiveRecord::Base
  belongs_to :production_dpt
  mount_uploader :file, MasterPlaneUploader
end
