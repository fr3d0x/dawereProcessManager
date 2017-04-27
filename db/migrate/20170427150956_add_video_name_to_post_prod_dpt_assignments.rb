class AddVideoNameToPostProdDptAssignments < ActiveRecord::Migration
  def change
    add_column :post_prod_dpt_assignments, :video_name, :string
  end
end
