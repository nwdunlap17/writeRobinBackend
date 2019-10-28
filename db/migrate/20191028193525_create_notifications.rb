class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :sender
      t.string :content
      t.boolean :invite, default: false
      t.boolean :follow, default: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
