CarrierWave.configure do |config|
  #set carrierwave new root folder
  config.root = '/mnt/hgfs/archivos_dpm'
  config.cache_dir = '/mnt/hgfs/archivos_dpm/tmp/uploads'
end
