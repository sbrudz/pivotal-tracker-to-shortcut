# frozen_string_literal: true

require 'dotenv/load'
require 'tracker_api'
require './converter'

client = TrackerApi::Client.new(token: ENV['PIVOTAL_API_TOKEN'])

project  = client.project(ENV['PIVOTAL_PROJECT_ID'])
stories = project.stories(filter: 'type:feature,chore,bug AND -state:accepted') #  AND label:shortcut
puts Converter.new(story: stories[1]).convert


