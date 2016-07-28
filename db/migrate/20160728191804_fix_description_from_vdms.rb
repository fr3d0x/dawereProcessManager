class FixDescriptionFromVdms < ActiveRecord::Migration
  def change
    rename_column :vdms, :Description, :description
  end
end
