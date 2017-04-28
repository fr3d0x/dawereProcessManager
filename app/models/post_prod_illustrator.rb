class PostProdIllustrator < ActiveRecord::Base
  belongs_to :post_prod_dpt_assignment
  mount_uploader :file, PostProdIllustratorUploader
end
