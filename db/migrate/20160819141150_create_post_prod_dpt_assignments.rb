class CreatePostProdDptAssignments < ActiveRecord::Migration
  def change
    create_table :post_prod_dpt_assignments do |t|
      t.string :status
      t.string :assignedName
      t.text :comments
      t.references :user, index: true
      t.references :post_prod_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :post_prod_dpt_assignments, :users
    add_foreign_key :post_prod_dpt_assignments, :post_prod_dpts
  end
end
