class CreateWacomVids < ActiveRecord::Migration
  def change
    create_table :wacom_vids do |t|
      t.string :file
      t.string :file_name
      t.references :production_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :wacom_vids, :production_dpts
  end
end
