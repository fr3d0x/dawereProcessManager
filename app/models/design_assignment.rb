class DesignAssignment < ActiveRecord::Base
  belongs_to :design_dpt
  belongs_to :user
  has_many :design_ilustrators, :dependent => :destroy
  has_many :design_jpgs, :dependent => :destroy
  has_many :design_elements, :dependent => :destroy
  mount_uploader :designed_presentation, DesignedPresentationUploader

end
