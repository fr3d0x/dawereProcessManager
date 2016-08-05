class CreateDesignDpts < ActiveRecord::Migration
  def change
    create_table :design_dpts do |t|
      t.string :status
      t.text :comments
      t.references :vdm, index: true

      t.timestamps null: false
    end
    add_foreign_key :design_dpts, :vdms
  end
end
