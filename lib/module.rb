# frozen_string_literal: true
require 'json'
require 'yaml'
require 'open-uri'
require 'pp'

module Path
  ROOT_DIR = File.dirname((File.expand_path(__FILE__))).split('/')[0...-1].join('/')
end

# リクエストの送信、確認などを行う
class APIClient
  # apiにリクエストを送信して、レスポンスとしてjsonを受け取る
  def request(request_url)
    sleep(2)
    failed ||= 0
    response = open(URI.encode(request_url))
    confirm_response(response)
  rescue
    puts 'failed'
    sleep(5)
    failed += 1
    retry if failed < 3
  end

  # パラメータ付きのリクエストURLを生成
  def create_url(url, params_hash)
    temp_array = []
    params_hash.each do |k, v|
      temp_array << "#{k}=#{v}" unless v.nil?
    end
    params = temp_array.join('&')
    "#{url}?#{params}"
  end

  private

  # レスポンスの内容を確認する
  def confirm_response(response)
    code, message = response.status
    return JSON.parse(response.read) if code == '200'
    puts "#{code} #{message}"
  end
end

# ファイルへ出力する
class FileOutput
  def self.export(result_hash, query)
    jan_codes = open("#{Path::ROT_DIR}/assets/jan_codes.json", 'r') do |io|
      JSON.load(io)
    end
    open("#{Path::ROT_DIR}/assets/jan_codes.json", 'w') do |io|
      if jan_codes.is_a?(Hash)
        if jan_codes.has_key?(query)
          jan_codes[query].concat(result_hash[query])
          jan_codes[query].uniq!
        else
          jan_codes[query] = result_hash[query]
        end
        JSON.dump(jan_codes, io)
      else
        JSON.dump(result_hash, io)
      end
    end
  end
end

# カテゴリ検索とレビュー検索のURLを作成する
class SearchInitializer
  # 初期化を行う
  attr_reader :value
  def initialize
    json_base_url = 'http://shopping.yahooapis.jp/ShoppingWebService/V1/json'
    # Yahoo shopping apiのID
    app_id = ENV['APPLICATION_ID']
    @value = {
      review: initialize_review_search(app_id, json_base_url),
      item: initialize_item_search(app_id, json_base_url)
    }
  end

  # initメソッドで用いる
  def initialize_review_search(app_id, json_base_url)
    [
      "#{json_base_url}/reviewSearch",
      {
        # startを変更することで複数件取得する。
        # startはオフセットと同様。
        # 件数の限界は不明。
        # 1件目は1
       appid: app_id, affiliate_type: nil, affiliate_id: nil, callback: nil,
       jan: nil, category_id: nil, product_id: nil, person_id: nil,
       store_id: nil, results: 50, start: nil, sort: nil
     }
    ]
  end

  # initメソッドで用いる
  def initialize_item_search(app_id, json_base_url)
    [
      "#{json_base_url}/itemSearch",
      {
        # offset + hitsの合計は1000が上限
        # →1000まで取得する。
        appid: app_id, query: nil, hits: 50, offset: nil
      }
    ]
  end
end
