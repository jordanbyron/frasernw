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
      start_date = dates.first
      end_date = dates.last
      metrics = ['visits', 'visitors', 'pageviews']
      sort = ['date']
      
      if @report.user_type_mask == -1
        #non admin
        dimensions = ['date', 'customVarValue2']
        filters = ["customVarValue2 != 0"]
      elsif @report.user_type_mask == 0
        #everyone
        dimensions = ['date']
        filters = []
      else
        #specific class
        dimensions = ['date', 'customVarValue2']
        filters = ["customVarValue2 == #{@report.user_type_mask}"]
      end
      
      #dimensions = @data.to_h['points'].map{ |entry| entry.to_h['dimensions'].reduce({}){|h, pairs| pairs.each {|k, v| h[k] = v}; h} }
      #metrics = @data.to_h['points'].map{ |entry| entry.to_h['metrics'].reduce({}){|h, pairs| pairs.each {|k, v| h[k] = v}; h} }
      
      results = get_data(start_date, end_date, dimensions, metrics, filters, sort)
      
      @visits = []
      @visitors = []
      @pageviews = []
      
      Array(dates.first..dates.last).each do |date|
        date_string = date.to_s(:yyyymmdd)
        @visits << results[date_string][:visits]
        @visitors << results[date_string][:visitors]
        @pageviews << results[date_string][:pageviews]
      end
      
      @h = LazyHighCharts::HighChart.new('graph') do |f|
        f.options[:chart][:defaultSeriesType] = "area"
        f.options[:plotOptions] = {areaspline: {pointInterval: 1.day, pointStart: dates.first.day}}
        f.options[:xAxis][:categories] = Array(dates.first..dates.last)
        f.options[:xAxis][:labels] = {}
        f.options[:xAxis][:labels][:step] = 7
        f.series(:name => 'Pageviews', :data => @pageviews)
        f.series(:name => 'Visits', :data => @visits)
        f.series(:name => 'Visitors', :data => @visitors)
      end
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
  
  def get_data(start_date, end_date, dimensions, metrics, filters, sort)
    
    ga = Gattica.new({ :email => ENV['GA_USER'], :password => ENV['GA_PASS'] })
    accounts = ga.accounts
    ga.profile_id = accounts.first.profile_id
    
    options = {
      :start_date => start_date.to_s,
      :end_date => end_date.to_s,
      :metrics => metrics,
      :dimensions => dimensions,
      :filters => filters,
      :sort => sort
    }
    @data = ga.get(options)
           
    results = {}
    @data.to_h['points'].each do |entry|
      entry_date = entry.to_h['dimensions'].first[:date]
      entry_metrics = entry.to_h['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
      results[entry_date] = entry_metrics
    end
    
    #fill in any missing data with zeros
    Array(start_date..end_date).each do |date|
      date_string = date.to_s(:yyyymmdd)
      results[date_string] = {} if results[date_string].blank?
      metrics.each do |metric|
        results[date_string][metric.to_sym] = 0 if results[date_string][metric.to_sym].blank?
      end
    end
    
    results
  end
  
  def get_start_end_date(report)
    case report.time_frame_mask
      when 1
        return [Date.today - 1, Date.today-1]
      when 2
        return [Date.today - 7, Date.today]
      when 3
        return [Date.today - 1.month, Date.today]
      when 4
        return [Date.today - 1.year, Date.today]
      when 5
        return [Date.new(2012,06,1), Date.today]
      when 6
        return [report.start_date, report.end_date]
      else
        return [Date.today - 1, Date.today]
      end
  end
end
