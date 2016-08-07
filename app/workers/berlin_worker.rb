require 'open3'
require 'uri'
require 'open-uri'
require 'open_uri_redirections'
require 'mp3info'
require 'soundcloud'

class BerlinWorker
  def self.create(title, text)
    file_list = convert_to_speech(text)
    mp3, duration = create_mp3(title, file_list)
  end

  protected
  def self.ssml_convert_to_speech(content, file_name, type = 'application/ssml+xml')
    content = <<-eos
      <speak>
        <break/>#{content}
      </speak>
    eos
    stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{content}\" \"#{type}\" ")
    stdout.read.split("\n")
  end

  # split the article into smaller pieces and run the text through node + ivona
  # - v2, use a tokenizer to split apart the content better
  def self.convert_to_speech(content, type = 'text/plain')
    piece = ''
    pieces = []
    responses = []

    content.scan(/[^\.!?]+[\.!?]/).map(&:strip).each do |sentence|
      piece += sentence + ' '
      if piece.length > 7500
        pieces << piece
        piece = ''
      end
    end
    pieces << piece;

    pieces.each_with_index do |piece, index|
      piece.gsub!('"', "'") # remove double quotes as they mess with the shonky shell-out below
      file_name = "rps-#{index}.mp3"
      responses << ssml_convert_to_speech(piece, file_name)
    end
    responses
  end

  # use mp3wrapto build/combine an mp3 with logo and metadata etc
  def self.create_mp3(title, file_list)
    normalised_title = Time.now.strftime('%d-%m-%Y-') + title.downcase.gsub(/\W/,'')

    # join together each audio line to create a full mp3
    file_list.collect{ |f| f.prepend(Rails.root.to_s + '/') }
    `mp3wrap #{Rails.root}/public/content/#{normalised_title}.mp3 #{file_list.join(' ')}`
    `mv #{Rails.root}/public/content/#{normalised_title}_MP3WRAP.mp3 #{Rails.root}/public/content/#{normalised_title}.mp3`
    `chmod 777 #{Rails.root}/public/content/#{normalised_title}.mp3`

    mp3 = '/public/content/' + normalised_title + '.mp3'
    begin
      Mp3Info.open(Rails.root.to_s + mp3) do |mp3|
        mp3.tag.title = title
        mp3.tag.artist = 'Radio Robot'
        mp3.tag.album = Date.today.to_s
      end
    rescue Mp3InfoEOFError
      # adding images is flaky right now, sigh
    end

    duration = Mp3Info.open(Rails.root.to_s + mp3).length

    return [mp3, duration]
  end
end
