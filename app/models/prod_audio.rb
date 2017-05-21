class ProdAudio < ActiveRecord::Base
  belongs_to :production_dpt
  mount_uploader :file, ProdAudioUploader
end