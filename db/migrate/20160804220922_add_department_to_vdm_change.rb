class AddDepartmentToVdmChange < ActiveRecord::Migration
  def change
    add_column :vdm_changes, :department, :string
  end
end
