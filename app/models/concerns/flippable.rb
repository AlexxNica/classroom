# frozen_string_literal: true
module Flippable
  extend ActiveSupport::Concern

  # Public: Returns the objects flipper id.
  #
  # Example:
  #
  #   current_user.flipper_id
  #   # => "User:1"
  #
  # Returns a string.
  def flipper_id
    "#{self.class}:#{id}"
  end

  # Public: Check to see if a feature is enabled for the object.
  #
  # Example:
  #
  # current_user.feature_enabled?(:team_management)
  # # => true
  #
  # @organization.feature_enabled?(:student_identifier)
  # # => false
  #
  # Returns a boolean.
  def feature_enabled?(feature_name)
    GitHubClassroom.flipper[feature_name].enabled?(self)
  end
end
