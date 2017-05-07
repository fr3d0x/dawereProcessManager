class RenameQaAnalysisToQaAssignment < ActiveRecord::Migration
  def change
    rename_table :qa_analyses, :qa_assignments
  end
end
