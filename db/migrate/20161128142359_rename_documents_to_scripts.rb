class RenameDocumentsToScripts < ActiveRecord::Migration
  def change
    rename_table :documents, :scripts
  end
end
