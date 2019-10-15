class CreateSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :submissions do |t|
      t.string :content
      t.string :user_id
      t.string :story_id
      t.integer :position
      t.boolean :canon, default: false

      t.timestamps
    end
  end
end
