# frozen_string_literal: true
module InvitationsControllerMethods
  extend ActiveSupport::Concern

  included do
    layout 'layouts/invitations'

    before_action :ensure_user_has_identifier,       only: [:show]
    before_action :check_user_not_previous_acceptee, only: [:show]

    helper_method :current_assignment, :current_invitation, :current_organization, :student_identifier
  end

  def identifier
    not_found if student_identifier || current_assignment.student_identifier_type.nil?
    @student_identifier = StudentIdentifier.new
  end

  def successful_invitation; end

  def submit_identifier
    @student_identifier = StudentIdentifier.new(new_student_identifier_params)
    if @student_identifier.save
      redirect_to group_assignment_invitation_path
    else
      render :identifier
    end
  end

  protected

  # Protected: Returns the assignmet or group assignment
  # that is linked to the `current_invitation`
  #
  # Returns either an Assignment or GroupAssignment.
  def current_assignment
    raise NotImplementedError
  end

  # Protected: Returns the invitation that is
  # currently being accepted.
  #
  # Returns either an AssignmentInvitation or GroupAssignmentInvitation.
  def current_invitation
    raise NotImplementedError
  end

  # Protected: Returns the `current_assignment`s organization
  #
  # Returns an Organization.
  def current_organization
    @organization ||= current_assignment.organization
  end

  def student_identifier
    @student_identifier ||= current_user.student_identifiers.where(
      organization: current_organization,
      student_identifier_type: current_assignment.student_identifier_type
    )
  end

  private

  # Private: Ensure that if the assignment requires an identifier
  # and the student doesn't have one, then we redirect them to create
  # an new identifier.
  #
  # Returns nothing.
  def ensure_user_has_identifier
    return unless current_assignment.student_identifier_type.present?
    return if student_identifier.present?
    redirect_to identifier_assignment_invitation_path
  end

  def new_student_identifier_params
    params
      .require(:student_identifier)
      .permit(:value)
      .merge(user: current_user,
             organization: organization,
             student_identifier_type: current_assignment.student_identifier_type)
  end

  # Protected: Returns the GitHub token scopes
  # necessary to use this functionality.
  #
  # Example:
  #   required_scopes
  #   # => ["user:email"]
  #
  # Returns an Array.
  def required_scopes
    raise NotImplementedError
  end
end
