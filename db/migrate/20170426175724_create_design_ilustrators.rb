class CreateDesignIlustrators < ActiveRecord::Migration
  def change
    create_table :design_ilustrators do |t|
      t.string :file
      t.string :file_name
      t.references :design_assignment, index: true

      t.timestamps null: false
    end
    add_foreign_key :design_ilustrators, :design_assignments
  end
end
