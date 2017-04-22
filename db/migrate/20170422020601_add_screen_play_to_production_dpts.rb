class AddScreenPlayToProductionDpts < ActiveRecord::Migration
  def change
    add_column :production_dpts, :screen_play, :string
  end
end
