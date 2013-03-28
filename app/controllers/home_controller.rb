class HomeController < ApplicationController
  def index
    @playlist = Playlist.new
  end

  def about
  end
end
