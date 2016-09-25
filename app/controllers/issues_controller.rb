class IssuesController < ApplicationController
  def index
    authorize! :index, Issue

    @init_data = {
      app: {
        issues: Denormalized.generate(:issues),
        issueSources: Issue::BRIEF_SOURCE_LABELS,
        assignees: User.developer.map do |user|
          [
            user.id,
            {
              id: user.id,
              name: user.name
            }
          ]
        end.to_h
      }
    }
  end

  def new
    authorize! :new, Issue
    @issue = Issue.new
  end

  def create
    authorize! :create, Issue

    @issue = Issue.new(params[:issue])

    if @issue.save
      @issue.subscriptions.each do |subscription|
        IssuesMailer.subscribed(subscription).deliver
      end

      redirect_to public_path(@issue)
    else
      render :new
    end
  end

  def edit
    @issue = Issue.find(params[:id])
    authorize! :edit, @issue
  end

  def show
    @issue = Issue.find(params[:id])
    authorize! :show, @issue
  end


  def update
    @issue = Issue.find(params[:id])
    authorize! :update, @issue

    before_update_subscription_ids = @issue.subscriptions.map(&:id)
    before_update_is_complete = @issue.completed?

    if @issue.update_attributes(params[:issue])

      @issue.subscriptions.reject do |subscription|
        before_update_subscription_ids.include?(subscription.id)
      end.each do |subscription|
        IssuesMailer.subscribed(subscription).deliver
      end

      if !before_update_is_complete && @issue.completed?
        @issue.subscriptions.each do |subscription|
          if subscription.subscriber.active? && subscription.subscriber.admin_or_super?
            IssuesMailer.completed(subscription).deliver
          end
        end
      end

      redirect_to public_path(@issue)
    else
      render :edit
    end
  end

  def destroy
    @issue = Issue.find(params[:id])
    authorize! :destroy, @issue

    @issue.destroy

    redirect_to issues_path, notice: "Issue has been destroyed"
  end

  def toggle_subscription
    @issue = Issue.find(params[:id])
    authorize! :toggle_subscription, @issue

    existing_subscription = @issue.subscriptions.find_by(
      user_id: current_user.id
    )
    if existing_subscription.nil?
      @issue.subscriptions.create(
        user_id: current_user.id
      )
      notice = "Successfully subscribed to issue."
    else
      existing_subscription.destroy

      notice = "Successfully unsubscribed from issue."
    end

    redirect_to public_path(@issue), notice: notice
  end

  private

  def public_path(issue)
    if issue.change_request?
      change_request_path(issue.source_id)
    else
      issue_path(issue)
    end
  end
end
