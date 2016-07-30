class RemoveDescriptionFromVdms < ActiveRecord::Migration
  def change
    remove_column :vdms,  :description
  end
end
