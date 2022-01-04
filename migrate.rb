# frozen_string_literal: true

require 'dotenv/load'
require 'tracker_api'

client = TrackerApi::Client.new(token: ENV['PIVOTAL_API_TOKEN'])

puts client.me.email
