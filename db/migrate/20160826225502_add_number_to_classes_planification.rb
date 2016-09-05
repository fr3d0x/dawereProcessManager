class AddNumberToClassesPlanification < ActiveRecord::Migration
  def change
    add_column :classes_planifications, :topicNumber, :int
  end
end
