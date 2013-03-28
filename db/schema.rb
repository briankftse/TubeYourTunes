# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121016092809) do

  create_table "playlist_items", :force => true do |t|
    t.string   "search"
    t.string   "video_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "playlist_items", ["search"], :name => "index_playlist_items_on_search"

  create_table "playlist_items_playlists", :id => false, :force => true do |t|
    t.integer "playlist_id"
    t.integer "playlist_item_id"
  end

  add_index "playlist_items_playlists", ["playlist_id", "playlist_item_id"], :name => "playlist_playlist_items_index"
  add_index "playlist_items_playlists", ["playlist_item_id", "playlist_id"], :name => "playlist_playlist_items_index_inverse"

  create_table "playlists", :force => true do |t|
    t.string   "url"
    t.string   "attachment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
