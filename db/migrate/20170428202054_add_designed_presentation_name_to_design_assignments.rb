class AddDesignedPresentationNameToDesignAssignments < ActiveRecord::Migration
  def change
    add_column :design_assignments, :designed_presentation_name, :string
  end
end
