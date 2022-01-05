# frozen_string_literal: true
require './story_converter'

# Builds converters to transform from pivotal to shortcut
class ConverterFactory
  attr_reader :members

  def initialize(members:)
    @members = members
  end

  def build_converter(story)
    StoryConverter.new(story: story, members: members)
  end
end
