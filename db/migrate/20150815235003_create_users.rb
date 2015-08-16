class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

    	t.string :uid
    	t.string :access_token
    	t.timestamps null: false

    end

    add_index :users, :uid, :unique => true
  end
end
