CarrierWave.configure do |config|
  #set carrierwave new root folder
  config.root = '/mnt/hfgs/railsDpmUploads/'
  config.cache_dir = '/mnt/hfgs/railsDpmUploads/tmp/uploads'
end
