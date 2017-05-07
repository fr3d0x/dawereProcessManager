class RenameTypeToVdmType < ActiveRecord::Migration
  def change
    rename_column :vdms, :type, :vdm_type
  end
end
