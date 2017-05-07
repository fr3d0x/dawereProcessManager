class AddVideoToPostProdDptAssignments < ActiveRecord::Migration
  def change
    add_column :post_prod_dpt_assignments, :video, :string
  end
end
