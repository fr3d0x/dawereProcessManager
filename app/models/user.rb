class User < ActiveRecord::Base
  belongs_to :employee
  has_many :roles, :dependent => :destroy
  has_many :subject_planifications, :dependent => :destroy
  has_many :design_assignments
  has_many :subjects
  has_many :production_dpt_assignments
  has_many :post_prod_dpt_assignments
  has_many :qa_assignments
  validates :username, presence: true
  validates :password, presence: true
  validates :status, presence: true
end
