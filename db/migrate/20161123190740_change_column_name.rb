class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :documents, :type, :docType
  end
end
