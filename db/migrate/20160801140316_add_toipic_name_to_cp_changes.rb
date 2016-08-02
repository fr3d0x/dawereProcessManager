class AddToipicNameToCpChanges < ActiveRecord::Migration
  def change
    add_column :cp_changes, :topicName, :string
  end
end
