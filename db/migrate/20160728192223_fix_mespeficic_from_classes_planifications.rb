class FixMespeficicFromClassesPlanifications < ActiveRecord::Migration
  def change
    rename_column :classes_planifications, :meSpeficicObjDesc, :meSpecificObjDesc

  end
end
