class HospitalsController < ApplicationController

  def index
    @init_data = {
      app: {
        currentUser: FilterTableAppState::CurrentUser.call(
          current_user: current_user
        ),
        issues: Denormalized.fetch(:issues)
      },
      ui: {
        persistentConfig: {
          divisionId: @division.id
        }
      }
    }
  end

  def new
    @issue = Issues.new
  end

  def create
    Issue.create(params[:issue])

    redirect_to issues_path
  end
end
