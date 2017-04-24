class AddVideoClipToProductionDptAssignments < ActiveRecord::Migration
  def change
    add_column :production_dpt_assignments, :video_clip, :string
  end
end
