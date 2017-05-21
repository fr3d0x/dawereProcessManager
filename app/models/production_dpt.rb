class ProductionDpt < ActiveRecord::Base
  has_one :production_dpt_assignment
  has_many :master_planes
  has_many :detail_planes
  has_many :wacom_vids
  has_many :prod_audios
  belongs_to :vdm
  mount_uploader :script, ScriptUploader
  mount_uploader :screen_play, ScreenPlayUploader

end
