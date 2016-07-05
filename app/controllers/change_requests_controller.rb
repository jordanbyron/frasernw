class ChangeRequestsController < ApplicationController
  def show
    @issue = Issue.find_by(source_id: params[:id])

    authorize! :show, @issue

    render "issues/show"
  end

  def index
    authorize! :index, :change_requests

    @init_data = {
      app: {
        currentUser: FilterTableAppState::CurrentUser.call(
          current_user: current_user
        ),
        changeRequests: Denormalized.generate(:change_requests),
        progressLabels: Issue::PROGRESS_LABELS
      },
      ui: {
        persistentConfig: {
          showIssueEstimates: ENV["SHOW_ISSUE_ESTIMATES"] == "true"
        }
      }
    }
  end
end
