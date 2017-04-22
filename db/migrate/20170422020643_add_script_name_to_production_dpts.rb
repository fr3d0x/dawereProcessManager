class AddScriptNameToProductionDpts < ActiveRecord::Migration
  def change
    add_column :production_dpts, :script_name, :string
  end
end
