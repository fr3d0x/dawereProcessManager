class User < ActiveRecord::Base
  belongs_to :employee

  validates :username, presence: true
  validates :password, presence: true
  validates :status, presence: true
end
