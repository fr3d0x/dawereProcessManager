class CreateDesignAssigments < ActiveRecord::Migration
  def change
    create_table :design_assigments do |t|
      t.string :status
      t.string :assignedName
      t.text :comments
      t.references :user, index: true
      t.references :design_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :design_assigments, :users
    add_foreign_key :design_assigments, :design_dpts
  end
end
