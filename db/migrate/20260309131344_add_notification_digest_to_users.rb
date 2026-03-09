class AddNotificationDigestToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notification_digest, :string, default: "off", null: false
    add_column :users, :last_notification_digest_at, :datetime
  end
end
