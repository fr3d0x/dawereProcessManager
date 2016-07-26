class AddUserRefToSubjectPlanifications < ActiveRecord::Migration
  def change
    add_reference :subject_planifications, :user, index: true, foreign_key: true
  end
end
