CarrierWave.configure do |config|
  #set carrierwave new root folder
  config.root = '/mnt/hgfs/railsDpmUploads/'
  config.cache_dir = '/mnt/hgfs//railsDpmUploads/tmp/uploads'
end
