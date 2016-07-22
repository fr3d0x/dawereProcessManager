class CreateClassesPlanifications < ActiveRecord::Migration
  def change
    create_table :classes_planifications do |t|

      t.string :meGeneralObjective
      t.string :meSpecificObjective
      t.text :meSpeficicObjDesc
      t.string :topicName
      t.string :videos
      t.references :subject_planification, index: true


      t.timestamps null: false
    end
    add_foreign_key :classes_planifications, :subject_planifications
  end
end
