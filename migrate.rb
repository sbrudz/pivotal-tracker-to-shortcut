# frozen_string_literal: true

require 'dotenv/load'
require 'tracker_api'
require 'shortcut_ruby'
require './converter_factory'
require './member_list_finder'

pivotal_client = TrackerApi::Client.new(token: ENV['PIVOTAL_API_TOKEN'])
shortcut_client = ShortcutRuby::Shortcut.new(ENV['SHORTCUT_API_TOKEN'])

project = pivotal_client.project(ENV['PIVOTAL_PROJECT_ID'])
members = MemberListFinder.new(shortcut_client: shortcut_client, pivotal_project: project).build
stories = project.stories(filter: 'type:feature,chore,bug AND -state:accepted AND label:shortcut AND -label:migrated')
factory = ConverterFactory.new(members: members)
puts "Found #{stories.count} stories to transfer"
formatted_stories = stories.map do |story|
  factory.build_converter(story).convert
end
results = shortcut_client.stories.bulk_create(stories: formatted_stories)
puts results
if results[:code] == '201'
  stories.each do |story|
    story.add_label('migrated')
    story.save
  end
end
