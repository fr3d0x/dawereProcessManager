class AddFirstPeriodCompletedToSubjectPlanifications < ActiveRecord::Migration
  def change
    add_column :subject_planifications, :firstPeriodCompleted, :boolean
  end
end
