class AddPeriodToClassesPlanifications < ActiveRecord::Migration
  def change
    add_column :classes_planifications, :period, :integer
  end
end
