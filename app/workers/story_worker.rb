#TODO be smarter when cleaning content - replace <p>, <i> and <b> with vocal/SSML tags
require 'open3'
require 'uri'
require 'open-uri'
require 'mp3info'
require 'soundcloud'

class StoryWorker
  include Sidekiq::Worker

  def perform(url)
    body = fetch_article_content(url)
    content = clean_article_content(body['content'])

    intro = body['title'] + ". <break strength='strong'/>" + Time.now.strftime("%A, %B #{Time.now.day.ordinalize}, %Y")
    title_file = ssml_convert_to_speech(intro, 'title.mp3')
    file_list = convert_to_speech(content)

    file_list = [title_file, file_list].flatten

    create_mp3(file_list, body['title'], body['lead_image_url'])
  end

  protected
  def fetch_article_content(article_url)
    # scrape the url for just the text (vis readability or instapaper)
    # - v2 find related articles and include those
    url = "http://readability.com/api/content/v1/parser?url=" + URI.escape(article_url) + '&token=' + Rails.application.secrets.readability_token
    response = HTTParty.get(url)
    JSON.parse(response.body)
  end

  # Remove html, tags, entities, newlines, etc
  # see: http://stackoverflow.com/questions/816085/removing-redundant-line-breaks-with-regular-expressions
  def clean_article_content(content)
    clean = ActionView::Base.full_sanitizer.sanitize(content)
    clean = clean.gsub(/<(?:.|\n)*?>/m, '')
    #clean = clean.gsub(/(?:(?:\r\n|\r|\n)\s*){2,}/i, '\n')
    clean = clean.gsub(/(<([^>]+)>)/i, '')
    clean = clean.gsub('&nbsp;', ' ')
    #clean = clean.gsub('\n', ' ')
    clean = HTMLEntities.new.decode(clean)
    clean.strip
  end

  def ssml_convert_to_speech(content, file_name, type = 'application/ssml+xml')
    content = <<-eos
      <speak>
        <break/>#{content}<break strength='x-strong'/>
      </speak>
    eos
    stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{content}\" \"#{type}\" ")
    stdout.read.split("\n")
  end

  # split the article into smaller pieces and run the text through node + ivona
  # - v2, use a tokenizer to split apart the content better
  def convert_to_speech(content, type = 'text/plain')
    piece = ''
    pieces = []
    responses = []

    content.scan(/[^\.!?]+[\.!?]/).map(&:strip).each do |sentence|
      piece += sentence + '. '
      if piece.length > 1000
        pieces << piece
        piece = ''
      end
    end
    pieces << piece;

    pieces.each_with_index do |piece, index|
      piece.gsub!('"', "'") # remove double quotes as they mess with the shonky shell-out below
      file_name = "rps-#{index}.mp3"
      #stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{piece}\" \"#{type}\" ")
      #responses << stdout.read.split("\n")
      responses << ssml_convert_to_speech(piece, file_name)
    end
    responses
  end

  # use ffmpeg to build/combine an mp3 with logo and metadata etc
  def create_mp3(file_list, title, image)
    normalised_title = Time.now.strftime('%d-%m-%Y-') + title.downcase.gsub(/\W/,'')

    # join together each audio line to create a full mp3
    `ffmpeg -i "concat:#{file_list.join('|')}" -c copy public/content/#{normalised_title}.mp3 -y`

    # add some metadata
    image = image.split(' ').first rescue nil
    cover_image = (image ? URI.parse(image) : File.new(Rails.root + 'app/assets/images/default_cover_image.jpg', 'rb'))
    cover_image.read rescue (cover_image = false)

    mp3 = 'public/content/' + normalised_title + '.mp3'
    Mp3Info.open(mp3) do |mp3|
      mp3.tag.title = title
      mp3.tag.artist = 'Real pirates ship'
      mp3.tag.album = Date.today.to_s
      mp3.tag.comment = ENV['URL']
      mp3.tag2.add_picture(cover_image.read) if cover_image
    end

    return mp3
  end

  def upload_to_soundcloud(mp3, title)
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
end
