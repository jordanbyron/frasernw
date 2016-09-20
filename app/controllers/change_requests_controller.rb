class ChangeRequestsController < ApplicationController
  def show
    @issue = Issue.find_by(source_id: params[:id])

    if @issue.nil?
      authorize! :index, :change_requests

      redirect_to change_requests_path,
        notice: "There is no change request matching that code."
    else
      authorize! :show, @issue

      render "issues/show"
    end
  end

  def index
    authorize! :index, :change_requests

    @init_data = {
      app: {
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
