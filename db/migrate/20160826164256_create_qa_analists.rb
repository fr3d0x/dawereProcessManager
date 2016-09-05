class CreateQaAnalists < ActiveRecord::Migration
  def change
    create_table :qa_analists do |t|
      t.string :status
      t.text :comments
      t.string :assignedName
      t.references :qa_dpt, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :qa_analists, :qa_dpts
    add_foreign_key :qa_analists, :users

  end
end
