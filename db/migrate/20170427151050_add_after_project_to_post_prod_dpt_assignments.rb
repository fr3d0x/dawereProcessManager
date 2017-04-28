class AddAfterProjectToPostProdDptAssignments < ActiveRecord::Migration
  def change
    add_column :post_prod_dpt_assignments, :after_project, :string
  end
end
