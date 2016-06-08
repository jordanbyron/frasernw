class IssuesController < ApplicationController
  def index
    authorize! :index, Issue

    @init_data = {
      app: {
        currentUser: FilterTableAppState::CurrentUser.call(
          current_user: current_user
        ),
        issues: Denormalized.generate(:issues),
        issueSources: Issue::BRIEF_SOURCE_LABELS,
        completionEstimateLabels: Issue::COMPLETION_ESTIMATE_LABELS
      }
    }
  end

  def edit
    @issue = Issue.find(params[:id])
    authorize! :edit, @issue
  end

  def new
    authorize! :new, Issue
    @issue = Issue.new
  end

  def show
    @issue = Issue.find(params[:id])
    authorize! :show, @issue
  end

  def create
    authorize! :create, Issue
    @issue = Issue.create(params[:issue])

    redirect_to issue_path(@issue)
  end

  def update
    @issue = Issue.find(params[:id])
    authorize! :update, @issue

    @issue.update_attributes(params[:issue])

    redirect_to issue_path(@issue)
  end

  def destroy
    @issue = Issue.find(params[:id])
    authorize! :update, @issue

    redirect_to
  end
end
