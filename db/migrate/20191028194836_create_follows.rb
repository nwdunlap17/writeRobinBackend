class CreateFollows < ActiveRecord::Migration[6.0]
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.references :following, polymorphic: true, null: false

      t.timestamps
    end
  end
end
