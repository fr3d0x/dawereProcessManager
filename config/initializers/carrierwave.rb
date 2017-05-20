CarrierWave.configure do |config|
  #set carrierwave new root folder
  config.root = '/mnt/railsDpmUploads/'
  config.cache_dir = '/mnt/railsDpmUploads/tmp/uploads'
end
