class FixComentsFromVdms < ActiveRecord::Migration
  def change
    rename_column :vdms, :coments, :comments

  end
end
