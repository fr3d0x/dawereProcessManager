class AddAfterProjectNameToPostProdDptAssignments < ActiveRecord::Migration
  def change
    add_column :post_prod_dpt_assignments, :after_project_name, :string
  end
end
