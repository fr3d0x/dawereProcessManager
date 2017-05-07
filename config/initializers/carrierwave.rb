CarrierWave.configure do |config|
  #set carrierwave new root folder
  config.root = '/mnt/hfgs/archivos_dpm/'
  config.cache_dir = '/mnt/hfgs/archivos_dpm/tmp/uploads'
end
