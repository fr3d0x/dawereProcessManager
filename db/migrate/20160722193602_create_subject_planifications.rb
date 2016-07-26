class CreateSubjectPlanifications < ActiveRecord::Migration
  def change
    create_table :subject_planifications do |t|
      t.string :status
      t.references :teacher, index: true
      t.references :subject, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :subject_planifications, :teachers
    add_foreign_key :subject_planifications, :subjects
    add_foreign_key :subject_planifications, :users
  end
end
