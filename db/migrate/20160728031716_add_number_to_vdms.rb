class AddNumberToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :number, :integer
  end
end
