class AddVideoIdToVdmChanges < ActiveRecord::Migration
  def change
    add_column :vdm_changes, :videoId, :string
  end
end
