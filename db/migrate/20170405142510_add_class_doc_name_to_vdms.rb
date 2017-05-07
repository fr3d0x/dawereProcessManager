class AddClassDocNameToVdms < ActiveRecord::Migration
  def change
    add_column :vdms, :class_doc_name, :string
  end
end
