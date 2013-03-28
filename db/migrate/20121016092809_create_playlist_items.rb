class CreatePlaylistItems < ActiveRecord::Migration
  def change
    create_table :playlist_items do |t|
      t.string :search
      t.string :video_id

      t.timestamps
    end

    add_index :playlist_items, :search

    create_table :playlist_items_playlists, :id => false do |t|
      t.integer :playlist_id
      t.integer :playlist_item_id
    end

    add_index :playlist_items_playlists, [:playlist_id, :playlist_item_id], :name => "playlist_playlist_items_index"
    add_index :playlist_items_playlists, [:playlist_item_id, :playlist_id], :name => "playlist_playlist_items_index_inverse"
  end
end
