class AddTypeToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :vdm_type, :string
  end
end
