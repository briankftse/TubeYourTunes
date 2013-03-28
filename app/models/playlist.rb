require 'file_size_validator'
require 'iconv'

class Playlist < ActiveRecord::Base
  attr_accessible :attachment, :url
  attr_accessor :yt

  has_and_belongs_to_many :playlist_items

  mount_uploader :attachment, AttachmentUploader

  validates :attachment,
    :presence => true,
    :file_size => {
      :maximum => 0.5.megabytes.to_i
    }

  #after_save :process

  def process
    search_terms = case File.extname(attachment.current_path)
    when ".txt"
      process_txt
    when ".xml"
      process_xml
    else
      false
    end

    search_terms.uniq!
    puts search_terms

    if search_terms
      @yt = create_youtube_client
      playlist = create_youtube_playlist
      add_videos_to_playlist(search_terms, playlist)

      update_attribute(:url, "http://www.youtube.com/playlist?list=" + playlist.playlist_id + "&feature=view_all")
    else
      return false
    end
  end

  # return an array of search terms
  def process_txt
    file = File.new(attachment.current_path, "r")

    begin
      lines = file.read.split("\r")
    rescue Exception => e
      file.rewind
      lines = Iconv.conv('utf-8', 'utf-16', file.read)
      lines = lines.split("\r")
    end

    lines.shift
    search_terms = []

    lines.each do |line|
      terms = line.split("\t")
      search_terms.push(terms[1] +  " " + terms[0])
    end

    search_terms
  end

  # return an array of search terms
  def process_xml
    # everything inside "dict"
    file = File.new(attachment.current_path)
    doc = Nokogiri::XML(file)

    # these are all our track nodes
    nodes = doc.root.children[1].css("dict").first.children.css("dict")
    search_terms = []

    nodes.each do |node|
      artist, name = ""
      node.children.each_with_index do |child, i|
        if !child.child.nil? && child.child.text == "Name"
          name = node.children[i+1].child.text
        elsif !child.child.nil? && child.child.text == "Artist"
          artist = node.children[i+1].child.text
        end
      end

      search_terms.push(artist + " " + name)
    end

    search_terms
  end

  def create_youtube_client

    # rotate the key so we dont run into capacity issues with youtube api
    dev_key = case DateTime.now.strftime("%Q") % 5
    when 0
      "AI39si7HYKUepkZTmoEX-u0AMLzqobniM5evI53UzMBO0EsETPo4oel6WURpmco929p8RsjNwfHyt10Dt3t1UoOAOkIrm4HnTQ"
    when 1
      "AI39si7CakSpjgRsQvaduASQ3Bk_wxXYBoBTKXMAbXIUcbAMxH7EahObarJoE1dgMjcQc5npmC54wjyyRk_3u3f4mdthN-cRmQ"
    when 2
      "AI39si4IPGnolFtaRAwSGybHnlprS5JGfD3-2RCc7Tx651VdJqO26UxIh8R_W-B2zdm2i0xC6HYrnKh4-mJbYOX0mRJrJ22MiA"
    when 3
      "AI39si4djK7WbjJp1zhjkesdlbXWVH0mjSQtLnz6-loLMbIFYJCp1Q0sI22vxx5fVe6qj3MYDI-M8I3bbUz_HyjDQLpsQqlFLw"
    when 4
      "AI39si4rXqhFMrawJGVjMMfubZBueyqyxiw13FZWHgoNp8Jumj8SW1TzProoGMCLXOwWXxuigBA04WwGhfa6pONc6EWvCOh42w"
    else
      "AI39si4rXqhFMrawJGVjMMfubZBueyqyxiw13FZWHgoNp8Jumj8SW1TzProoGMCLXOwWXxuigBA04WwGhfa6pONc6EWvCOh42w"
    end

    yt = YouTubeIt::Client.new(:username => "playlists@tubeyourtunes.com",
                               :password =>  "",
                               :dev_key => dev_key)
  end

  def create_youtube_playlist
    playlist = @yt.add_playlist(:title => "youtubemymusic.com " +
                                              DateTime.now.strftime("%s"))
  end

  def add_videos_to_playlist(search_terms, playlist)
    search_terms.each do |search_term|
      playlist_item = get_playlist_item(search_term)
      if playlist_item
        begin
          @yt.add_video_to_playlist(playlist.playlist_id,
                                               playlist_item.video_id)
          self.playlist_items.push(playlist_item)
        rescue Exception => e
          puts e.inspect
        end
      end
    end
  end

  def get_playlist_item(search_term)
    playlist_item = PlaylistItem.find_by_search(search_term)

    if playlist_item.nil?
      video_id = get_youtube_video(search_term)
      if video_id
        playlist_item = PlaylistItem.create(:search => search_term, :video_id => video_id)
      else
        playlist_item = nil
      end
    end

    playlist_item
  end

  def get_youtube_video( search_term)
    @yt.videos_by(:query => search_term,
                             :categories => { :include => ["music"] },
                             :per_page => 1).videos.first.video_id
  end
end
