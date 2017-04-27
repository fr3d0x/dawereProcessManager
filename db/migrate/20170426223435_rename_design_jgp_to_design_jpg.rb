class RenameDesignJgpToDesignJpg < ActiveRecord::Migration
  def change
    rename_table :design_jgps, :design_jpgs
  end
end
