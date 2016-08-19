class PostProdDpt < ActiveRecord::Base
  belongs_to :vdm
  has_one :post_prod_dpt_assignment
end
