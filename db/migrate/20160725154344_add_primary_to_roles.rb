class AddPrimaryToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :primary, :boolean
  end
end
