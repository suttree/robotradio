#TODO be smarter when cleaning content - replace <p>, <i> and <b> with vocal/SSML tags
require 'open3'
require 'uri'
require 'open-uri'
require 'mp3info'
require 'soundcloud'

namespace :story do
  desc "Create a story from a url, run rake story:create URL=http://www.newyorker.com/books/joshua-rothman/what-are-the-odds-we-are-living-in-a-computer-simulation"
  task :create => :environment do
    body = fetch_article_content(ENV['URL'])
    content = clean_article_content(body['content'])
    file_list = convert_to_speech(content)

    mp3 = create_mp3(file_list, body['title'], body['lead_image_url'])
    track = upload_to_soundcloud(mp3, body['title'])

    puts "Story created: #{track.permalink_url}"
  end

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

  def ssml_convert_to_speech(content, type = 'application/ssml+xml')
    file_name = "title.mp3"
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
      stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{piece}\" \"#{type}\" ")
      responses << stdout.read.split("\n")
    end

    #content.split(/\n\n/).each do |paragraph|
    #  paragraph.gsub!(/(?:(?:\r\n|\r|\n)\s*){2,}/i, '')
    #  paragraph.gsub!('\n', '')
    #  paragraph.strip!
    #  next if paragraph.blank?
    #  pieces << paragraph + ".    "
    #end
    #
    #type = 'application/ssml+xml'
    #pieces.each_with_index do |piece, index|
    #  piece.gsub!('"', "'") # remove double quotes as they mess with the shonky shell-out below
    #  file_name = "rps-#{index}.mp3"
    #  piece_in_ssml = <<-eos
    #    <speak>
    #      <p>
    #        <break strength='strong' />
    #        <s>#{piece}</s>
    #        <break strength='x-strong' />
    #      </p>
    #    </speak>
    #  eos
    #  stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{piece_in_ssml}\" \"#{type}\" ")
    #  responses << stdout.read.split("\n")
    #end
    responses
  end

  # use ffmpeg to build/combine an mp3 with logo and metadata etc  
  def create_mp3(file_list, title, image)
    normalised_title = title.downcase.gsub(/\W/,'')

    # join together each audio line to create a full mp3
    `ffmpeg -i "concat:#{file_list.join('|')}" -c copy content/#{normalised_title}.mp3 -y`

    # add some metadata
    image = image.split(' ').first rescue nil
    cover_image = (image ? URI.parse(image) : File.new(Rails.root + 'app/assets/images/default_cover_image.jpg', 'rb'))
    cover_image.read rescue (cover_image = false)

    mp3 = 'content/' + normalised_title + '.mp3'
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
