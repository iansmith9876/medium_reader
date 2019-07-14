require 'rest-client'
require 'json'

class Reader
  def initialize(username)
    @username = username
  end

  def fetch_posts
    response = RestClient.get("https://medium.com/@#{@username}/latest?format=json", {accept: :json})
    posts_data = JSON.parse(response.body[16..-1]).dig("payload", "references", "Post")
    collect_posts(posts_data)
  end

  private

  def collect_posts(posts_data)
    posts_data.values.each_with_object([]) do |post, posts|
      posts << create_post(post)
    end
  end

  def create_post(post_data)
    {
      title: post_data.dig("title"),
      subtitle: post_data.dig("content", "subtitle"),
      readingTime: post_data.dig("virtuals", "readingTime"),
      totalClapCount: post_data.dig("virtuals", "totalClapCount"),
      publishedAt: Time.at(post_data.dig("firstPublishedAt").to_i/1000),
      imageUrl: "https://cdn-images-1.medium.com/max/1600/" + post_data.dig("virtuals", "previewImage", "imageId"),
      link: "https://medium.com/@#{@username}/" + post_data.dig("uniqueSlug")
    }
  end
end
