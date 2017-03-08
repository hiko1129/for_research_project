# frozen_string_literal: true
require 'module'
require 'store'

# レビュー情報を取得する
class ReviewProvider
  def before_provide_for_url
    search_initializer = SearchInitializer.new
    search_initializer.value[:review]
  end

  def before_provide_for_main(ids)
    [APIClient.new, ReviewView.new(ids, 'Reviewの取得')]
  end

  def provide(jan_codes)
    review_search_url, review_search_params = before_provide_for_url
    api_client, view = before_provide_for_main(jan_codes)
    # 商品レビュー検索のためのパラメータ付きリクエストURLを生成
    jan_codes.each_with_index do |jan, index|
      review_search_params[:jan] = jan
      view.show_index(index + 1)
      1.step(951, 50) do |i|
        review_search_params[:start] = i
        view.show_start(i)
        reviews = fetch(api_client, review_search_url, review_search_params)
        break unless extract(reviews)
      end
    end
  end

  def fetch(api_client, review_search_url, review_search_params)
    review_search_request_url = api_client.create_url(review_search_url,
                                                      review_search_params)

    # 商品レビュー検索APIにアクセスしてjsonを取得
    api_client.request(review_search_request_url)
  end

  def extract(reviews)
    return if reviews.nil?
    return nil if reviews['ResultSet']['totalResultsAvailable'] == '0'
    reviews['ResultSet']['Result'].each do |review|
      next unless review.include?('Ratings')
      rate = review['Ratings']['Rate']
      title = review['ReviewTitle']
      description = review['Description']
      save(rate: rate, title: title, content: description) unless description.empty?
    end
  end

  def save(review_data)
    YahooReview.create(review_data)
  end
  public :provide
end

# 状態を表示する
class ReviewView
  def initialize(jan_codes, type)
    @size = jan_codes.size
    puts type
  end

  def show_index(index)
    puts "index:#{index}/#{@size}"
  end

  def show_start(start)
    puts "start:#{start}"
  end

end
