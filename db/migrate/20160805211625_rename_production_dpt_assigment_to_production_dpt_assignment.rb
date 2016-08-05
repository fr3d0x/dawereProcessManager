class RenameProductionDptAssigmentToProductionDptAssignment < ActiveRecord::Migration
  def change
    rename_table :production_dpt_assigments, :production_dpt_assignments
  end
end
