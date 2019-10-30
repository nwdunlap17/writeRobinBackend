class AddSenderIdToNotifications < ActiveRecord::Migration[6.0]
  change_table :notifications do |t|
      t.integer :sender_id, default: 0
  end
end
