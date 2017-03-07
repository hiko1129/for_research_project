# frozen_string_literal: true
$LOAD_PATH.unshift File.dirname((File.expand_path(__FILE__)))
require 'core'

core_manager = CoreManager.new
core_manager.fetch_review
