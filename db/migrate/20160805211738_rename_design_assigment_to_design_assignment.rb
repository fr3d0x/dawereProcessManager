class RenameDesignAssigmentToDesignAssignment < ActiveRecord::Migration
  def change
    rename_table :design_assigments, :design_assignments
  end
end
