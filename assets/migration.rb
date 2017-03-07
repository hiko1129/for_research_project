# frozen_string_literal: true
require 'bundler/setup'
require 'active_record'
require 'yaml'

# database.yamlを読み込んで利用する
config = YAML.load_file('../config/database.yml')
ActiveRecord::Base.establish_connection(config['db']['development'])

# スキーマを設定
class InitialSchema < ActiveRecord::Migration
  def change
    create_table :yahoo_reviews do |t|
      create_review_table(t)
    end
  end

  private

  def create_review_table(t)
    t.integer :rate
    t.text :title
    t.text :content
    t.timestamps null: false
  end
end

# マイグレーション
InitialSchema.migrate(:change)
