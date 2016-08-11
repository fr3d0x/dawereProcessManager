class CreateProductManagements < ActiveRecord::Migration
  def change
    create_table :product_managements do |t|
      t.string :productionStatus
      t.string :editionStatus
      t.string :designStatus
      t.string :postProductionStatus
      t.references :vdm, index: true

      t.timestamps null: false
    end
    add_foreign_key :product_managements, :vdms

  end
end
