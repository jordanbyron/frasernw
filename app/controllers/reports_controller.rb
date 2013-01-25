class ReportsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @reports = Report.all
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @report = Report.find(params[:id])
    
    ga = Gattica.new({ :email => ENV['GA_USER'], :password => ENV['GA_PASS'] })
    accounts = ga.accounts
    ga.profile_id = accounts.first.profile_id
    
    case @report.type_mask
    when 1
      #report on general page views
      dates = get_start_end_date(@report)
      @data = ga.get({
                     :start_date => dates.first.to_s,
                     :end_date => dates.last.to_s,
                     :dimensions => ['day', 'customVarValue2'],
                     :metrics => ['visits', 'visitors'],
                     :filters => ["customVarValue2 == #{@report.user_type_mask}"]})
    else
      @data = nil
    end
    
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @report = Report.new
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def create
    @report = Report.new(params[:report])
    if @report.save
      redirect_to @report, :notice => "Successfully created report."
      else
      render :action => 'new'
    end
  end
  
  def edit
    @report = Report.find(params[:id])
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def update
    @report = Report.find(params[:id])
    if @report.update_attributes(params[:report])
      redirect_to @report, :notice  => "Successfully updated report."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    redirect_to reports_url, :notice => "Successfully deleted report."
  end
  
  private
  
  def get_start_end_date(report)
    case report.time_frame_mask
      when 1
        return [Date.today - 1, Date.today - 1]
      when 2
        return [Date.today - 7, Date.today - 1]
      when 3
        return [Date.today - 1.month, Date.today - 1]
      when 4
        return [Date.today - 1.year, Date.today - 1]
      when 5
        return [Date.today - 100.year, Date.today - 1]
      when 6
        return [report.start_date, report.end_date]
      else
        return [Date.today - 1, Date.today - 1]
      end
  end
end
