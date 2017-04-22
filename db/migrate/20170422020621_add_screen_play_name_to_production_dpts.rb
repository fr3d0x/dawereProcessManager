class AddScreenPlayNameToProductionDpts < ActiveRecord::Migration
  def change
    add_column :production_dpts, :screen_play_name, :string
  end
end
