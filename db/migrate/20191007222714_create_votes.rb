class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.string :submission_id
      t.string :user_id
      t.boolean :positive

      t.timestamps
    end
  end
end
