class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
    	t.string :name, :limit => 64, null: false
      t.string :itunes_app_id
      t.string :request_origin_url, :limit => 255

      #foreign key
      t.integer :user_id

    	t.timestamps null: false
    end
  end
end
