class RemoveTeacherFilesFromVdms < ActiveRecord::Migration
  def change
    remove_column :vdms, :teacher_files, :json
  end
end
