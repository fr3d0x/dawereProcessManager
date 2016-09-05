class AddDurationToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :duration, :float
  end
end
