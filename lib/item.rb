# frozen_string_literal: true
require 'module'

# Categoryの処理を行う
class ItemProvider
  # カテゴリーを処理するための準備
  def initialize
    search_initializer = SearchInitializer.new
    item = search_initializer.value[:item]
    @item_search_url, @item_search_params = item
  end

  # janコードを抽出していく処理
  def gets_jan(query)
    response_array = fetch_jan(query)
    extract_jan(response_array, query)
  end

  private

  # どのカテゴリIDを処理しているかを標準出力する
  # sleepの時間も表示する
  def display_status(jan)
    puts "jan:#{jan}"
    puts 'wait 4 seconds'
    puts
  end

  # janコードを取得
  def fetch_jan(query)
    @item_search_params[:query] = query
    max_offset = 950
    view = ItemView.new(max_offset, query + 'のJANコードの取得')
    api_client = APIClient.new
    response_array = []
    0.step(max_offset, 50) do |i|
      view.show_status(i)
      @item_search_params[:offset] = i
    # カテゴリID取得のためのパラメータ付きリクエストURLを生成
      jan_search_request_url = api_client.create_url(@item_search_url,
                                                        @item_search_params)
      # カテゴリID取得APIにアクセスしてjsonを取得
      response_array << api_client.request(jan_search_request_url)
    end
    response_array
  end

  def extract_jan(response_array, query)
    view = ItemView.new(response_array.size, query + 'のJANコードの抽出')
    response_array.each_with_index do |response, idx|
      view.show_status(idx + 1)
      jan_codes = { "#{query}" => [] }
      response['ResultSet']['0']['Result'].each do |data|
        if data[1].is_a?(Hash) && !data[1]['JanCode'].blank?
          jan_code = data[1]['JanCode']
          jan_codes["#{query}"] << jan_code if compare_gs1(jan_code)
        end
      end
      FileOutput.export(jan_codes, query)
    end
  end

  def compare_gs1(jan_code)
    yaml = YAML.load_file("#{Path::ROOT_DIR}/config/search.yml")
    yaml['gs1'].each do |gs1|
      if jan_code =~ /^#{gs1}/
        return true
      else
        return false
      end
    end
  end
end

# 状態を表示する
class ItemView
  def initialize(response_array_size, type)
    @size = response_array_size
    puts type
  end

  def show_status(index)
    puts "#{index}/#{@size}"
  end
end
