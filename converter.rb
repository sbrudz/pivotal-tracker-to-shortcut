# frozen_string_literal: true

# Converts a pivotal story to shortcut format
class Converter
  attr_reader :story

  def initialize(story:)
    @story = story
  end

  def convert
    {
      'name': story.name,
      'project_id': ENV['SHORTCUT_PROJECT_ID'],
      'description': story.description,
      'external_id': story.id,
      'labels': convert_labels,
      'story_type': story.story_type,
      'tasks': convert_tasks,
      'requested_by_id': '61b36229-f039-4506-b760-8e33d3b04df6', # TK
      'comments': convert_comments
    }
  end

  private

  def convert_tasks
    story.tasks.map { |task| convert_task(task) }
  end

  def convert_labels
    story.labels.map { |label| convert_label(label) } + [{ 'name': 'pivotal' }]
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
      'author_id': 123, # TODO: use a real author id
      'external_id': comment.id,
      'text': comment.text,
      'created_at': comment.created_at,
      'updated_at': comment.updated_at
    }
  end
end
