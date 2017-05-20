class AddFieldsToProductionDpt < ActiveRecord::Migration
  def change
    add_column :production_dpts, :master_plane, :string
    add_column :production_dpts, :detailed_plane, :string
    add_column :production_dpts, :wacom_vid, :string
    add_column :production_dpts, :prod_audio, :string
  end
end
