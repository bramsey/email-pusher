class CreateNotificationServices < ActiveRecord::Migration
  def self.up
    create_table :notification_services do |t|
      t.integer :user_id
      t.string :type
      t.string :username

      t.timestamps
    end
  end

  def self.down
    drop_table :notification_services
  end
end
