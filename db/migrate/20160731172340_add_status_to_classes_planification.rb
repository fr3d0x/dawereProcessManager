class AddStatusToClassesPlanification < ActiveRecord::Migration
  def change
    add_column :classes_planifications, :status, :string
  end
end
