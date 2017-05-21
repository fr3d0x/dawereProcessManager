class RemoveFieldsFromProductionDpts < ActiveRecord::Migration
  def change
    remove_column :production_dpts, :master_plane, :string
    remove_column :production_dpts, :detailed_plane, :string
    remove_column :production_dpts, :wacom_vid, :string
    remove_column :production_dpts, :prod_audio, :string
  end
end
