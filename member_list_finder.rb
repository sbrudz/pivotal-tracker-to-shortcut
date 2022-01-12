# frozen_string_literal: true

# Converts a pivotal user id to a shortcut user id
class MemberListFinder
  attr_reader :shortcut_client, :pivotal_project

  FUZZY_EMAIL_REGEX = /(.+@.+)\./.freeze

  def initialize(shortcut_client:, pivotal_project:)
    @shortcut_client = shortcut_client
    @pivotal_project = pivotal_project
  end

  def build
    pivotal_members.map do |pivotal_member|
      shortcut_member = shortcut_members.find do |member|
        pivotal_email = pivotal_member[:pivotal_email]
        shortcut_email = member[:shortcut_email]
        pivotal_email == shortcut_email ||
          pivotal_member[:pivotal_name] == member[:shortcut_name] ||
          pivotal_email.slice(FUZZY_EMAIL_REGEX) == shortcut_email.slice(FUZZY_EMAIL_REGEX)
      end || { shortcut_id: 'Not Found' }
      pivotal_member.merge(shortcut_member)
    end
  end

  private

  def shortcut_members
    shortcut_client.members.list[:content].filter_map do |member|
      if member['disabled'] == false
        {
          shortcut_id: member['id'],
          shortcut_email: member['profile']['email_address'],
          shortcut_name: member['profile']['name']
        }
      end
    end
  end

  def pivotal_members
    pivotal_project.memberships.map do |member|
      person = member.person
      {
        pivotal_id: person.id,
        pivotal_email: person.email,
        pivotal_name: person.name
      }
    end
  end
end
