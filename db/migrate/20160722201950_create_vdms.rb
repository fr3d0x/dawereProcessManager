class CreateVdms < ActiveRecord::Migration
  def change
    create_table :vdms do |t|
      t.string :videoId
      t.string :videoTittle
      t.text :videoContent
      t.string :status
      t.text :coments
      t.text :Description
      t.references :classes_planification, index: true

      t.timestamps null: false
    end
    add_foreign_key :vdms, :classes_planifications
  end
end
