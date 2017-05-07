class AddClassDocToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :classDoc, :text
  end
end
