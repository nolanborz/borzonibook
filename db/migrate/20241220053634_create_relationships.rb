# db/migrate/20241220053634_create_relationships.rb
class CreateRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.references :follower, foreign_key: { to_table: :users }
      t.references :followed, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :relationships, [ :follower_id, :followed_id ], unique: true
  end
end
