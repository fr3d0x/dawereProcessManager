class QaAssignment < ActiveRecord::Base
  belongs_to :qa_dpt
  belongs_to :user
end
