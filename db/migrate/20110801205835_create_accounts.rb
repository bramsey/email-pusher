class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :username
      t.integer :user_id
      t.boolean :active
      t.string :token
      t.string :secret
      t.integer :notification_service_id

      t.timestamps
    end
    
    add_index :accounts, :user_id, :name => "index_accounts_on_user_id"
  end

  def self.down
    drop_table :accounts
  end
end
