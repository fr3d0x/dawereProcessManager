class AddVideoClipNameToProductionDptAssignments < ActiveRecord::Migration
  def change
    add_column :production_dpt_assignments, :video_clip_name, :string
  end
end
