class AddGradeToSubject < ActiveRecord::Migration
  def change
    add_reference :subjects, :grade, index: true, foreign_key: true
  end
end
