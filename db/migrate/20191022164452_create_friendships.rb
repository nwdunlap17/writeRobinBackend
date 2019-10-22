class CreateFriendships < ActiveRecord::Migration[6.0]
  def change
    create_table :friendships do |t|
      t.integer :user1
      t.integer :user2

      t.timestamps
    end
  end
end
