class AddUsersToSubject < ActiveRecord::Migration
  def change
    add_reference :subjects, :user, index: true, foreign_key: true
  end
end
