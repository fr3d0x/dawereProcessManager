class AddFileNameToTeacherFiles < ActiveRecord::Migration
  def change
    add_column :teacher_files, :file_name, :string
  end
end
