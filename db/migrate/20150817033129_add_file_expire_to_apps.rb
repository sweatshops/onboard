class AddFileExpireToApps < ActiveRecord::Migration
  def up
    add_column :apps, :expire, :date
    add_column :apps, :download_link, :text
  end

  def down
    remove_column :apps, :expire
    remove_column :apps, :download_link
  end
end
