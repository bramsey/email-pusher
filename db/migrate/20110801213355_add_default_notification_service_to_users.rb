class AddDefaultNotificationServiceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_notification_service_id, :integer
  end

  def self.down
    remove_column :users, :default_notification_service_id
  end
end
