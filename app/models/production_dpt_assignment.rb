class ProductionDptAssignment < ActiveRecord::Base
  belongs_to :production_dpt
  belongs_to :user
  mount_uploader :video_clip, VideoClipUploader
  mount_uploader :premier_project, PremierProjectUploader
end
