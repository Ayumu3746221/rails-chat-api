class ChangeRoleTypeInUsers < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :role, :integer, using: "CASE WHEN role = 'parent' THEN 0 WHEN role = 'child' THEN 1 ELSE NULL END"
  end

  def down
    change_column :users, :role, :string, using: "CASE WHEN role = 0 THEN 'parent' WHEN role = 1 THEN 'child' ELSE NULL END"
  end
end