# frozen_string_literal: true
require './story_converter'

# Builds converters to transform from pivotal to shortcut
class ConverterFactory
  attr_reader :members, :workflow_state_mapper

  def initialize(members:, workflow_state_mapper:)
    @members = members
    @workflow_state_mapper = workflow_state_mapper
  end

  def build_converter(story)
    StoryConverter.new(story: story, members: members, workflow_state_mapper: workflow_state_mapper)
  end
end
