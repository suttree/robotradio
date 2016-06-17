require 'open3'
require 'uri'
require 'open-uri'
require 'mp3info'

namespace :story do
  desc "Create a story from a url, run rake story:create URL=http://www.newyorker.com/books/joshua-rothman/what-are-the-odds-we-are-living-in-a-computer-simulation"
  task :create => :environment do
    body = fetch_article_content(ENV['URL'])
    content = clean_article_content(body['content'])
    file_list = convert_to_speech(content)
    mp3 = create_mp3(file_list, body['title'], body['lead_image_url'])
    # upload it to soundcloud
    # https://github.com/moumar/ruby-mp3info
    # https://github.com/soundcloud/soundcloud-ruby
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
    clean = clean.gsub(/(?:(?:\r\n|\r|\n)\s*){2,}/i, '\n')
    clean = clean.gsub(/(<([^>]+)>)/i, '')
    clean = clean.gsub('&nbsp;', ' ')
    clean = HTMLEntities.new.decode(clean)
    clean = clean.strip
  end

  # run the text through node + ivona
  # - v2, use a tokenizer to split apart the content better
  def convert_to_speech(content)
    responses = []
    content.scan(/[^\.!?]+[\.!?]/).map(&:strip).each_with_index do |line, index|
      file_name = "rps-#{index}.mp3"
      stdin, stdout, stderr = Open3.popen3("node script/ivona.js \"#{file_name}\" \"#{line}\" ")
      responses << stdout.read.split("\n")
    end
    responses
  end

  # use ffmpeg to build/combine an mp3 with logo and metadata etc  
  def create_mp3(file_list, title, image)
    cover_image = (image ? URI.parse(image) : File.new(Rails.root + 'app/assets/images/default_cover_image.jpg', 'rb'))
    normalised_title = title.downcase.gsub(/\W/,'')

    # join together each audio line to create a full mp3
    `ffmpeg -i "concat:#{file_list.join('|')}" -c copy content/#{normalised_title}.mp3 -y`

    # add some metadata
    mp3 = 'content/' + normalised_title + '.mp3'
    #file = File.new(cover_image,'rb')
    file = cover_image
    Mp3Info.open(mp3) do |mp3|
      mp3.tag.title = title
      mp3.tag.artist = 'Real pirates ship'
      mp3.tag.album = Date.today.to_s
      mp3.tag2.add_picture(file.read)
    end

    return mp3
  end
end
