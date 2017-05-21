class DetailPlane < ActiveRecord::Base
  belongs_to :production_dpt
  mount_uploader :file, DetailedPlaneUploader

end
