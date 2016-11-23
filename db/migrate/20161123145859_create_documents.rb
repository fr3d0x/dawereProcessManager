class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :vdm, index: true, foreign_key: true
      t.string :file

      t.timestamps null: false
    end
  end
end
