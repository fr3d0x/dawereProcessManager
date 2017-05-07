class CreatePostProdIllustrators < ActiveRecord::Migration
  def change
    create_table :post_prod_illustrators do |t|
      t.string :file
      t.string :file_name
      t.references :post_prod_dpt_assignment, index: true

      t.timestamps null: false
    end
    add_foreign_key :post_prod_illustrators, :post_prod_dpt_assignments
  end
end
