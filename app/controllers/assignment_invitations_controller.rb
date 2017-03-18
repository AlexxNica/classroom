# frozen_string_literal: true
class AssignmentInvitationsController < ApplicationController
  include InvitationsControllerMethods

  before_action :check_user_not_previous_acceptee, only: [:show]
  before_action :ensure_github_repo_exists, only: [:successful_invitation]

  def accept_invitation
    create_assignment_repo { redirect_to successful_invitation_assignment_invitation_path }
  end

  def show; end

  def identifier
    not_found if student_identifier || assignment.student_identifier_type.nil?
    @student_identifier = StudentIdentifier.new
  end

  def submit_identifier
    @student_identifier = StudentIdentifier.new(new_student_identifier_params)
    if @student_identifier.save
      redirect_to assignment_invitation_path
    else
      render :identifier
    end
  end

  private

  def required_scopes
    GitHubClassroom::Scopes::ASSIGNMENT_STUDENT
  end

  def assignment_repo
    @assignment_repo ||= AssignmentRepo.find_by(assignment: assignment, user: current_user)
  end
  helper_method :assignment_repo

  def create_assignment_repo
    result = invitation.redeem_for(current_user)

    if result.success?
      yield if block_given?
    else
      flash[:error] = result.error
      redirect_to assignment_invitation_path(invitation)
    end
  end

  def check_user_has_identifier
    return unless assignment.student_identifier_type.present?
    return if student_identifier.present?
    redirect_to identifier_assignment_invitation_path
  end

  def check_user_not_previous_acceptee
    return unless assignment.users.include?(current_user)
    redirect_to successful_invitation_assignment_invitation_path
  end

  def ensure_github_repo_exists
    return not_found unless assignment_repo
    return if assignment_repo
              .github_repository
              .present?(headers: GitHub::APIHeaders.no_cache_no_store)

    assignment_repo.destroy
    @assignment_repo = nil
    create_assignment_repo
  end
end
