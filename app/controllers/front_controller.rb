class FrontController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper
  
  def index
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end