class CreateProdAudios < ActiveRecord::Migration
  def change
    create_table :prod_audios do |t|
      t.string :file
      t.string :file_name
      t.references :production_dpt, index: true

      t.timestamps null: false
    end
    add_foreign_key :prod_audios, :production_dpts
  end
end
