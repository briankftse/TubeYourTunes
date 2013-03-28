class PlaylistItem < ActiveRecord::Base
   attr_accessible :search, :video_id
  has_and_belongs_to_many :playlists
end
