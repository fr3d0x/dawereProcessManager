class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.text :cvLong
      t.text :cvShort
      t.string :firstName
      t.string :middleName
      t.string :lastName
      t.string :personalId

      t.timestamps null: false
    end
  end
end
