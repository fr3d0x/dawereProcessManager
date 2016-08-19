class CreatePostProdDpts < ActiveRecord::Migration
  def change
    create_table :post_prod_dpts do |t|
      t.string :status
      t.text :comments
      t.references :vdm, index: true

      t.timestamps null: false
    end
    add_foreign_key :post_prod_dpts, :vdms
  end
end
