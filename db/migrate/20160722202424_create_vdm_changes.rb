class CreateVdmChanges < ActiveRecord::Migration
  def change
    create_table :vdm_changes do |t|
      t.date :changeDate
      t.text :changeDetail
      t.text :changedFrom
      t.text :changedTo
      t.references :vdm, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :vdm_changes, :vdms
    add_foreign_key :vdm_changes, :users

  end
end
