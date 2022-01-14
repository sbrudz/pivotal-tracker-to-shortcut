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
factory = ConverterFactory.new(members: members)

dry_run = ENV['DRY_RUN'] == 'true'
puts '** Running in DRY_RUN mode - No updates will be made **' if dry_run

stories = project.stories(filter: 'type:feature,chore,bug AND -state:accepted AND label:shortcut AND -label:migrated_to_shortcut')
puts "Found #{stories.count} stories to transfer"

stories.each_slice(10) do |batch_of_stories|
  print "Transferring stories #{batch_of_stories.map(&:id)}"
  formatted_stories = batch_of_stories.map do |story|
    factory.build_converter(story).convert
  end

  if dry_run
    puts '...Dry run complete'
  else
    results = shortcut_client.stories.bulk_create(stories: formatted_stories)

    raise "Error #{results[:code]} encountered" unless results[:code] == '201'

    batch_of_stories.each do |story|
      story.add_label('migrated_to_shortcut')
      story.save
    end
    puts '...Success!'
  end
  sleep 5
end
puts "#{dry_run ? 'Dry run' : 'Transfer'} complete"
