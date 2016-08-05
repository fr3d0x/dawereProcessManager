class User < ActiveRecord::Base
  belongs_to :employee
  has_many :roles, :dependent => :destroy
  has_many :subject_planifications, :dependent => :destroy
  has_many :design_assigments
  has_one :product_dpt_assigments
  validates :username, presence: true
  validates :password, presence: true
  validates :status, presence: true
end
