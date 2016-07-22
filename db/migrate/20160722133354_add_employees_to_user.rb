class AddEmployeesToUser < ActiveRecord::Migration
  def change
    add_reference :users, :employees, index: true, foreign_key: true
  end
end
