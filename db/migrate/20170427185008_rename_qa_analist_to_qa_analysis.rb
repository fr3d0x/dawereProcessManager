class RenameQaAnalistToQaAnalysis < ActiveRecord::Migration
  def change
    rename_table :qa_analists, :qa_analyses
  end
end
