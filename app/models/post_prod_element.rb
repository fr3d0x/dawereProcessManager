class PostProdElement < ActiveRecord::Base
  belongs_to :post_prod_dpt_assignment
  mount_uploader :file, PostProdElementUploader
end
