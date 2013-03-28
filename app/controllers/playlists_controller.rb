class PlaylistsController < ApplicationController

  def create
    @playlist = Playlist.new(params[:playlist])
    if @playlist.save && @playlist.process
      respond_to do |format|
        format.html {
          redirect_to @playlist
        }
        format.json  {
          flash[:notice] = "Successfully created painting."
          redirect_to @playlist
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "Something went wrong :("
          render :action => 'new'
        }
      end
    end
  end

  def show
    @playlist = Playlist.find(params[:id])
  end
end
