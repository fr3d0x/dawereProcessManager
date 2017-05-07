class AddTypeToDesignDpt < ActiveRecord::Migration
  def change
    add_column :design_dpts, :type, :string
  end
end
