class CreateTeacherFiles < ActiveRecord::Migration
  def change
    create_table :teacher_files do |t|
      t.string :file
      t.references :vdm, index: true

      t.timestamps null: false
    end
    add_foreign_key :teacher_files, :vdms
  end
end
