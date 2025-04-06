class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string
    # カラムを追加している、User.wehre(role: "parent")などで探すことができる
    add_index :users, :role
  end
end
