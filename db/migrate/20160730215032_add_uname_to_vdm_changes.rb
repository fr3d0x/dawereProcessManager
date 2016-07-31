class AddUnameToVdmChanges < ActiveRecord::Migration
  def change
    add_column :vdm_changes, :uname, :string
  end
end
