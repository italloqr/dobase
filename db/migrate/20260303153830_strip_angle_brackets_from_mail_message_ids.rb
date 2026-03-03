# frozen_string_literal: true

class StripAngleBracketsFromMailMessageIds < ActiveRecord::Migration[8.1]
  def up
    # Strip angle brackets from message_id to match in_reply_to/references format
    execute <<~SQL
      UPDATE mail_messages
      SET message_id = REPLACE(REPLACE(message_id, '<', ''), '>', '')
      WHERE message_id LIKE '<%'
    SQL

    # Reset thread_ids so the before_save callback recalculates them
    # with consistent message_id formats
    say_with_time "Re-threading all mail messages" do
      count = 0
      Mails::Message.find_each do |msg|
        msg.update_column(:thread_id, nil)
        msg.send(:set_thread_id)
        msg.update_column(:thread_id, msg.thread_id)
        count += 1
      end
      count
    end
  end

  def down
    # No-op: can't restore original angle brackets or thread_ids
  end
end
