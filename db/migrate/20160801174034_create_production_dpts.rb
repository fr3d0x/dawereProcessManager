class CreateProductionDpts < ActiveRecord::Migration
  def change
    create_table :production_dpts do |t|
      t.string :status
      t.text :script, :limit => 4294967295
      t.text :comments
      t.boolean :intro
      t.boolean :vidDev
      t.boolean :conclu
      t.references :vdm, index: true

      t.timestamps null: false
    end
    add_foreign_key :production_dpts, :vdms

  end
end
