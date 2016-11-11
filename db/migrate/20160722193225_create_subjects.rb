class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.text :shortDescription
      t.text :longDescription
      t.string :grade
      t.text :firstPeriodDesc
      t.text :secondPeriodDesc
      t.text :thirdPeriodDesc
      t.text :goal
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :subjects, :users
  end
end
