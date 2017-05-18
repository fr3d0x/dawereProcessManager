class Vdm < ActiveRecord::Base
  belongs_to :classes_planification
  has_many :vdm_changes
  has_many :teacher_files
  has_one :production_dpt
  has_one :production_dpt_assignment , :through => :production_dpt
  has_one :design_dpt
  has_one :design_assignment , :through => :design_dpt
  has_one :product_management
  has_one :post_prod_dpt
  has_one :post_prod_dpt_assignment , :through => :post_prod_dpt
  has_one :qa_dpt
  has_one :qa_assignment , :through => :qa_dpt
  mount_uploader :classDoc, ClassDocUploader
end
