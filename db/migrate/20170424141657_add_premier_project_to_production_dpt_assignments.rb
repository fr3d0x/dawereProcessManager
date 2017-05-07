class AddPremierProjectToProductionDptAssignments < ActiveRecord::Migration
  def change
    add_column :production_dpt_assignments, :premier_project, :string
  end
end
