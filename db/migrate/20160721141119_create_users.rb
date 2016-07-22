class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :profilePicture
      t.string :status
      t.references :employee, index: true

      t.timestamps null: false
    end
    add_foreign_key :users, :employees
  end
end
