# frozen_string_literal: true
$LOAD_PATH.unshift File.dirname((File.expand_path(__FILE__))) + '/lib'
require 'core'

core_manager = CoreManager.new
core_manager.fetch_review
