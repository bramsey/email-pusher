class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :email
      t.boolean :approved, :default => false

      t.timestamps
    end
    
    add_index :invites, :email, :unique => true
  end

  def self.down
    drop_table :invites
  end
end
