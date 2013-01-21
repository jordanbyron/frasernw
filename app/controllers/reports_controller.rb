class ReportsController < ApplicationController
  load_and_authorize_resource
  
  def index
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end