require 'open3'
require 'uri'
require 'open-uri'
require 'open_uri_redirections'
require 'mp3info'
require 'soundcloud'

class StoryWorker
  def self.create(url)
    body = fetch_article_content(url)
    content = clean_article_content(body['content'])

    intro = body['title'] + ". <break strength='strong'/>" + Time.now.strftime("%A, %B #{Time.now.day.ordinalize}, %Y")
    title_file = ssml_convert_to_speech(intro, 'title.mp3')
    file_list = convert_to_speech(content)
    file_list = [title_file, file_list].flatten

    mp3, image, duration = create_mp3(file_list, body['title'], body['lead_image_url'], url)
    create_show(mp3, body['title'], url, image, duration) #if (duration/60 > 2) # don't register short tracks
    add_to_playlist(mp3)
  end

  protected
  def self.fetch_article_content(article_url)
    # scrape the url for just the text (vis readability or instapaper)
    # - v2 find related articles and include those
    #url = "http://readability.com/api/content/v1/parser?url=" + URI.escape(article_url) + '&token=' + Rails.application.secrets.readability_token

    url = 'https://mercury.postlight.com/parser?url=' + URI.escape(article_url) 
    headers = {
      'Content-Type' => 'application/json',
      'x-api-key' => Rails.application.secrets.postlight_token
    }
    response = HTTParty.get(url, :headers => headers)
    JSON.parse(response.body)
  end

  # Remove html, tags, entities, newlines, etc
  # see: http://stackoverflow.com/questions/816085/removing-redundant-line-breaks-with-regular-expressions
  def self.clean_article_content(content)
    clean = ActionView::Base.full_sanitizer.sanitize(content)
    clean = clean.gsub(/<(?:.|\n)*?>/m, '')
    #clean = clean.gsub(/(?:(?:\r\n|\r|\n)\s*){2,}/i, '\n')
    clean = clean.gsub(/(<([^>]+)>)/i, '')
    #clean = clean.gsub('\n', ' ')
    clean = HTMLEntities.new.decode(clean)
    clean = clean.gsub('&nbsp;', ' ')
    clean = clean.gsub('&', 'and')
    clean.strip
  end

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
  def self.create_mp3(file_list, title, image, url)
    normalised_title = Time.now.strftime('%d-%m-%Y-') + title.downcase.gsub(/\W/,'')

    # join together each audio line to create a full mp3
    file_list.collect{ |f| f.prepend(Rails.root.to_s + '/') }
    `mp3wrap #{Rails.root}/public/content/#{normalised_title}.mp3 #{file_list.join(' ')}`
    `mv #{Rails.root}/public/content/#{normalised_title}_MP3WRAP.mp3 #{Rails.root}/public/content/#{normalised_title}.mp3`
    `chmod 777 #{Rails.root}/public/content/#{normalised_title}.mp3`

    # add some metadata
    image = image.split(' ').first rescue nil
    cover_image = (image ? URI.parse(image) : File.new(Rails.root + 'app/assets/images/default_cover_image.jpg', 'rb'))
    show_image = cover_image
    cover_image.read rescue (cover_image = false)

    mp3 = '/public/content/' + normalised_title + '.mp3'
    begin
      Mp3Info.open(Rails.root.to_s + mp3) do |mp3|
        mp3.tag.title = title
        mp3.tag.artist = 'Radio Robot'
        mp3.tag.album = Date.today.to_s
        mp3.tag.comment = url
        mp3.tag2.add_picture(cover_image.read) if cover_image
      end
    rescue Mp3InfoEOFError
      # adding images is flaky right now, sigh
    end

    duration = Mp3Info.open(Rails.root.to_s + mp3).length

    return [mp3, show_image, duration]
  end

  def self.upload_to_soundcloud(mp3, title)
    client = Soundcloud.new(
                  :client_id => Rails.application.secrets.soundcloud_client_id,
                  :client_secret => Rails.application.secrets.soundcloud_client_secret,
                  :username      => Rails.application.secrets.soundcloud_username,
                  :password      => Rails.application.secrets.soundcloud_password
                )

    client.post('/tracks', :track => {
      :title => title,
      :asset_data => File.new(mp3, 'rb')
    })
  end

  def self.create_show(mp3, title, url, image, duration)
    Show.create(
      :title => title,
      :slug => title.to_url,
      :url => url,
      :filename => mp3.gsub('/public', ''),
      :image => image.path,
      :cover_image => image,
      :duration => duration
    )
  end

  def self.add_to_playlist(mp3)
    open(Rails.root.to_s + 'icecast.playlist', 'a') do |f|
      f << Rails.root.to_s + mp3
    end
  end
end
