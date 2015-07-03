class TermsAndConditionsController < ApplicationController
  include ApplicationHelper

  def index
    authorize! :index, :terms_and_conditions
  end
end
