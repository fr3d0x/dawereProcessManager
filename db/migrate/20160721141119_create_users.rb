class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :role
      t.string :profilePicture
      t.string :status

      t.timestamps null: false
    end
  end
end
