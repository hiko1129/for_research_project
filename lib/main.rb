# frozen_string_literal: true
$LOAD_PATH << '.'
require 'core'

core_manager = CoreManager.new
core_manager.fetch_review
