require 'open3'

namespace :story do
  desc "Create a story from a url, run rake story:create URL=http://www.newyorker.com/books/joshua-rothman/what-are-the-odds-we-are-living-in-a-computer-simulation"
  task :create => :environment do
    body = fetch_article_content(ENV['URL'])
    content = clean_article_content(body['content'])
    file_list = convert_to_speech(content)
    # use ffmpeg to build/combine an mp3 with logo and metadata etc
    # upload it to soundcloud
  end

  def fetch_article_content(url)
    require 'uri'
    # scrape the url for just the text (vis readability or instapaper)
    # - v2 find related articles and include those
    url = "http://readability.com/api/content/v1/parser?url=" + URI.escape(url) + '&token=' + Rails.application.secrets.readability_token
    response = HTTParty.get(url)
    #puts response.body, response.code, response.message, response.headers.inspect

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
  def convert_to_speech(content)
    stdin, stdout, stderr = Open3.popen3("timeout 10 phantomjs scraper.js \"#{url}\" ")
    responses = stdout.read.split("\n")
  end
  
  def create_mp3(file_list)
    stdin, stdout, stderr = Open3.popen3('ffmpeg -i "' + file_list.slice(0, -1) + '" -c copy content/' + Date.now() +'.mp3 -y')
  end
end
