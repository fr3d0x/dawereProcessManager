class AddTypeToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :type, :string
  end
end
