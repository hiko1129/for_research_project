# frozen_string_literal: true
require 'bundler/setup'
require 'active_record'
require 'yaml'

# database.yamlを読み込んで利用する
config = YAML.load_file("#{Path::ROOT_DIR}/config/database.yml")
ActiveRecord::Base.establish_connection(config['db']['development'])

# 使用できるようにするための継承
class YahooReview < ActiveRecord::Base
end
