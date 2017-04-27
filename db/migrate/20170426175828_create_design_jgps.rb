class CreateDesignJgps < ActiveRecord::Migration
  def change
    create_table :design_jgps do |t|
      t.string :file
      t.string :file_name
      t.references :design_assignment, index: true

      t.timestamps null: false
    end
    add_foreign_key :design_jgps, :design_assignments
  end
end
