class AddTeacherFilesToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :teacher_files, :string
  end
end
