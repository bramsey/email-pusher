class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :email
      t.integer :user_id
      t.boolean :active, :default => true

      t.timestamps
    end
    
    add_index :contacts, :email, :unique => true
  end

  def self.down
    drop_table :contacts
  end
end
