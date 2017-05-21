class CreateMasterPlanes < ActiveRecord::Migration
  def change
    create_table :master_planes do |t|
      t.string :file
      t.string :file_name
      t.references :production_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :master_planes, :production_dpts
  end
end
