class ChangeRequestsController < ApplicationController
  def index
    authorize! :index, :change_requests

    @init_data = {
      app: {
        currentUser: FilterTableAppState::CurrentUser.call(
          current_user: current_user
        ),
        changeRequests: Denormalized.generate(:change_requests),
        completionEstimateLabels: Issue::COMPLETION_ESTIMATE_LABELS,
        progressLabels: Issue::PROGRESS_LABELS
      }
    }
  end
end
