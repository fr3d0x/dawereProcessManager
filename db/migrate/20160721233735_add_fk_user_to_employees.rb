class AddFkUserToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :fk_user, :integer
  end
end
