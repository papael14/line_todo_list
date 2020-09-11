class AddUsernameToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :username, :string, after: :body
  end
end
