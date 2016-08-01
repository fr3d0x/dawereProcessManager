class CreateCpChanges < ActiveRecord::Migration
  def change
    create_table :cp_changes do |t|
      t.date :changeDate
      t.string :changeDetail
      t.text :changedFrom
      t.text :changedTo
      t.text :comments
      t.string :uname

      t.references :classes_planification, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :cp_changes, :classes_planifications
    add_foreign_key :cp_changes, :users
  end
end
