class PostProdDptAssignment < ActiveRecord::Base
  belongs_to :post_prod_dpt
  belongs_to :user
  mount_uploader :video, FinalVidUploader
  mount_uploader :premier_project, PostProdPremierUploader
  mount_uploader :after_project, PostProdAfterUploader
  has_many :post_prod_elements
  has_many :post_prod_illustrators
end
