class AddCommentsToVdmChanges < ActiveRecord::Migration
  def change
    add_column :vdm_changes, :comments, :text
  end
end
