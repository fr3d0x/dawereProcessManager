class ProductionDpt < ActiveRecord::Base
  has_one :production_dpt_assignment
  belongs_to :vdm
  mount_uploader :script, ScriptUploader
  mount_uploader :screen_play, ScreenPlayUploader

end
