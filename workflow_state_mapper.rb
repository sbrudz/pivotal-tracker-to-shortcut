# frozen_string_literal: true

# Converts a pivotal state to a shortcut workflow state
class WorkflowStateMapper
  attr_reader :shortcut_client

  def initialize(shortcut_client:)
    @shortcut_client = shortcut_client
  end

  def get_shortcut_state_id(pivotal_state)
    found_entry = mapping.find { |entry| entry['pivotal_state'] == pivotal_state }
    raise "Unmapped pivotal state #{pivotal_state}; Please update WORKFLOW_MAPPING_JSON" unless found_entry

    shortcut_state = shortcut_workflow_states.find { |state| state[:name] == found_entry['shortcut_state'] }
    raise "Shortcut state #{found_entry['shortcut_state']} does not exist in workflow #{shortcut_workflow_id}" unless shortcut_state

    shortcut_state[:id]
  end

  private

  def mapping
    @mapping ||= JSON.parse(ENV['WORKFLOW_MAPPING_JSON'])
  end

  def shortcut_workflow_id
    ENV['SHORTCUT_WORKFLOW_ID']
  end

  def shortcut_workflow_states
    @shortcut_workflow_states ||= shortcut_client.workflows(shortcut_workflow_id)
                                  .list[:content]['states'].map do |state|
      { name: state['name'], id: state['id'] }
    end
  end
end
