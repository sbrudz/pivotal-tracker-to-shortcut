# frozen_string_literal: true

# Converts a pivotal story to shortcut format
class StoryConverter
  attr_reader :story, :members, :workflow_state_mapper

  def initialize(story:, members:, workflow_state_mapper:)
    @story = story
    @members = members
    @workflow_state_mapper = workflow_state_mapper
  end

  def convert
    {
      'name': story.name,
      'project_id': ENV['SHORTCUT_PROJECT_ID'],
      'description': story.description || '',
      'external_id': story.id.to_s,
      'external_links': [story.url],
      'created_at': story.created_at,
      'updated_at': story.updated_at,
      'labels': convert_labels,
      'story_type': story.story_type,
      'tasks': convert_tasks,
      'requested_by_id': convert_user_id_to_member_id(story.requested_by_id),
      'comments': convert_comments,
      'owner_ids': convert_owners,
      'workflow_state_id': convert_workflow_state_id
    }
  end

  private

  def convert_tasks
    story.tasks.map { |task| convert_task(task) }
  end

  def convert_owners
    return [] unless story.owner_ids.present?

    story.owner_ids.map { |owner_id| convert_user_id_to_member_id(owner_id) }
  end

  def convert_labels
    existing_labels = story.labels.present? ? story.labels.map { |label| convert_label(label) } : []
    add_has_attachments_label(existing_labels) + [{ 'name': 'pivotal' }]
  end

  def convert_workflow_state_id
    workflow_state_mapper.get_shortcut_state_id(story.current_state)
  end

  def add_has_attachments_label(labels)
    attachments? ? labels + [{ 'name': 'has_attachments_in_pivotal' }] : labels
  end

  def attachments?
    story.comments.any? { |comment| comment.attachments.present? }
  end

  def convert_comments
    story.comments.map { |comment| convert_comment(comment) }
  end

  def convert_task(task)
    {
      'complete': task.complete,
      'description': task.description,
    }
  end

  def convert_label(label)
    {
      'name': label['name'],
    }
  end

  def convert_comment(comment)
    {
      'author_id': convert_user_id_to_member_id(comment.person_id),
      'external_id': comment.id.to_s,
      'text': comment.text,
      'created_at': comment.created_at,
      'updated_at': comment.updated_at
    }
  end

  def convert_user_id_to_member_id(pivotal_id)
    user = members.find do |member|
      member[:pivotal_id] == pivotal_id
    end
    user[:shortcut_id]
  end
end
