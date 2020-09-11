class AddUserToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :user, :string, after: :id
  end
end
