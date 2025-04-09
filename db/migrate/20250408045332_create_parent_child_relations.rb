class CreateParentChildRelations < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_child_relations do |t|
      t.references :parent, null: false, foreign_key: { to_table: :users }
      t.references :child, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    # 親子関係の一意性を確保するためのインデックス
    add_index :parent_child_relations, [:parent_id, :child_id], unique: true
  end
end
