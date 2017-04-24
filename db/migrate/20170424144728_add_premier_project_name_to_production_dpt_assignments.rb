class AddPremierProjectNameToProductionDptAssignments < ActiveRecord::Migration
  def change
    add_column :production_dpt_assignments, :premier_project_name, :string
  end
end
