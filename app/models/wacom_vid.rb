class WacomVid < ActiveRecord::Base
  belongs_to :production_dpt
  mount_uploader :file, WacomVidUploader
end

