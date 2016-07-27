class RemoveGradeFromSubject < ActiveRecord::Migration
  def change
    remove_column :subjects, :grade, :string
  end
end
