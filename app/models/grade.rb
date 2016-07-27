class Grade < ActiveRecord::Base
  has_many :subjects, :dependent => :destroy
end
