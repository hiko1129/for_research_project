# frozen_string_literal: true
require 'reviews'
require 'item'

# 全体を扱うクラス
class CoreManager
  def fetch_jan_codes
    item_provider = ItemProvider.new
    # FIXME
    # 全てのファイルパスの記述
    yaml = YAML.load_file('../config/search.yml')
    yaml['query'].each do |query|
      item_provider.gets_jan(query)
    end
  end

  def fetch_review
    # janコードファイルの初期化
    open('../assets/jan_codes.json', 'w') do |io|
      io = nil
    end
    # janコードの取得
    fetch_jan_codes
    # janコードが記載されたファイルに基づきレビューを取得
    open('../assets/jan_codes.json', 'r') do |io|
      jan_codes = JSON.load(io)
      merged_jan_codes = []
      jan_codes.each_value do |array|
        merged_jan_codes.concat(array)
      end
      open('../assets/jan_codes.json', 'w') do |io2|
        JSON.dump({ uniq: merged_jan_codes.uniq }, io2)
      end
      review_provider = ReviewProvider.new
      review_provider.provide(merged_jan_codes.uniq)
    end
  end
end
