class QaDpt < ActiveRecord::Base
  belongs_to :vdm
  has_one :qa_analist
end
