class CreateStories < ActiveRecord::Migration[6.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.string :user_id
      t.integer :length, default: 20
      t.string :intro
      t.boolean :public, default: true
      t.integer :round_unique_users, default: 0

      t.timestamps
    end
  end
end
