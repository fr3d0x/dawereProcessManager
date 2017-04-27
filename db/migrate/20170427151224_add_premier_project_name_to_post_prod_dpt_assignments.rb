class AddPremierProjectNameToPostProdDptAssignments < ActiveRecord::Migration
  def change
    add_column :post_prod_dpt_assignments, :premier_project_name, :string
  end
end
