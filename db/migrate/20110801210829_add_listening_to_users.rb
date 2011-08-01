class AddListeningToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :listening, :boolean
  end

  def self.down
    remove_column :users, :listening
  end
end
