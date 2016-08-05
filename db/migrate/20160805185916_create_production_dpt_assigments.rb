class CreateProductionDptAssigments < ActiveRecord::Migration
  def change
    create_table :production_dpt_assigments do |t|
      t.string :status
      t.string :assignedName
      t.text :comments
      t.references :user, index: true
      t.references :production_dpt, index:true

      t.timestamps null: false
    end
    add_foreign_key :production_dpt_assigments, :users
    add_foreign_key :production_dpt_assigments, :production_dpts
  end
end
