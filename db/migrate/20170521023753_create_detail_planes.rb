class CreateDetailPlanes < ActiveRecord::Migration
  def change
    create_table :detail_planes do |t|
      t.string :file
      t.string :file_name
      t.references :production_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :detail_planes, :production_dpts
  end
end
