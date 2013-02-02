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
      dimensions = []
      filters = []
      sort = []
      
      if @report.user_type_mask == -1
        #non admin
        dimensions << 'customVarValue2'
        filters << "customVarValue2 != 0"
      elsif @report.user_type_mask == 0
        #everyone
      else
        #specific class
        dimensions << 'customVarValue2'
        filters << "customVarValue2 == #{@report.user_type_mask}"
      end
      
      results = get_data_by_date(start_date, end_date, dimensions, metrics, filters, sort)
      
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
      
      if @report.by_user
        user_dimensions = dimensions
        user_dimensions.delete('date')
        user_results = get_data_by_user(start_date, end_date, user_dimensions, metrics, filters, [])
        @user_results = []
        puts user_results
        user_results.each do |user_id, metrics|
          user = User.find_by_id(user_id)
          @user_results << [ user.name, metrics[:visits], metrics[:visitors], metrics[:pageviews] ] if user.present?
        end
      end
    when 4
      #report on content items
      
      #grab the page views
      dates = get_start_end_date(@report)
      start_date = dates.first
      end_date = dates.last
      metrics = ['pageviews']
      dimensions = []
      filters = ["pagePath =@ content_items"]
      sort = []
      
      if @report.user_type_mask == -1
        #non admin
        dimensions << 'customVarValue2'
        filters << "customVarValue2 != 0"
      elsif @report.user_type_mask == 0
        #everyone
      else
        #specific user class
        dimensions << 'customVarValue2'
        filters << "customVarValue2 == #{@report.user_type_mask}"
      end
      
      results_markdown = get_data_by_date_and_path(start_date, end_date, dimensions, metrics, filters, sort)
      
      total_pageviews = []
      
      # we conly care about markdown content items; links and documents we will get via the 'outgoing links' events
      markdown_ids = ScItem.markdown.reject{ |i| @report.only_shared_care && !i.shared_care }.map{ |c| "#{c.id}" }
      
      Array(dates.first..dates.last).each_with_index do |date, date_index|
        date_string = date.to_s(:yyyymmdd)
        total_pageviews[date_index] = 0
        results_markdown[date_string].each do |path, metrics|
          next if !markdown_ids.include?(path.split('/').last)
          total_pageviews[date_index] += metrics[:pageviews]
        end
      end
      
      if @report.by_pageview
        results = get_data_by_path(start_date, end_date, dimensions, metrics, filters, sort)
        puts results
        by_page_pageviews_map = {}
        results.each do |path, metrics|
          content_item_id = path.split('/').last.to_i
          next if !markdown_ids.include?(content_item_id)
          content_item = ScItem.find_by_id(content_item_id)
          next if @report.only_shared_care && !content_item.shared_care
          by_page_pageviews_map[content_item_id] = [ content_item.title, metrics[:pageviews] ] if content_item.present?
        end
      end
      
      #grab the 'outgoing links' events, cobmine into results
      
      metrics = ['totalEvents']
      dimensions = ['eventCategory', 'eventAction']
      filters = ["eventCategory =@ content_item_id", "eventAction == #{ScItem::TYPE_LINK}"]
      sort = []
      
      if @report.user_type_mask == -1
        #non admin
        dimensions << 'customVarValue2'
        filters << "customVarValue2 != 0"
      elsif @report.user_type_mask == 0
        #everyone
      else
        #specific user class
        dimensions << 'customVarValue2'
        filters << "customVarValue2 == #{@report.user_type_mask}"
      end
      
      results_outgoing = get_data_by_date(start_date, end_date, dimensions, metrics, filters, sort)
      
      Array(dates.first..dates.last).each_with_index do |date, date_index|
        date_string = date.to_s(:yyyymmdd)
        total_pageviews[date_index] += results_outgoing[date_string][:totalEvents]
      end
      
      if @report.by_pageview
        results = get_data_by_path(start_date, end_date, dimensions, metrics, filters, sort)
        puts results
        results.each do |path, metrics|
          next if !path.starts_with?('/content_items/')
          content_item_id = path.split('/').last.to_i
          content_item = ScItem.find_by_id(content_item_id)
          by_page_pageviews_map[content_item_id] = [ content_item.title, metrics[:totalEvents] ] if content_item.present?
        end
        
        @by_page_pageviews = []
        ScItem.all.each do |sc_item|
          next if sc_item.sc_category.inline?
          if by_page_pageviews_map[sc_item.id].blank?
            @by_page_pageviews << [sc_item.title, 0]
          else
            @by_page_pageviews << by_page_pageviews_map[sc_item.id]
          end
        end
      end
      
      #Graph it
      
      @h = LazyHighCharts::HighChart.new('graph') do |f|
        f.options[:chart][:defaultSeriesType] = "area"
        f.options[:plotOptions] = {areaspline: {pointInterval: 1.day, pointStart: dates.first.day}}
        f.options[:xAxis][:categories] = Array(dates.first..dates.last)
        f.options[:xAxis][:labels] = {}
        f.options[:xAxis][:labels][:step] = 7
        f.series(:name => 'Pageviews', :data => total_pageviews)
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
  
    return ga.get(options)
  end
  
  def get_data_by_date(start_date, end_date, dimensions, metrics, filters, sort)
    
    dimensions =  ['date'] + dimensions
    data = get_data(start_date, end_date, dimensions, metrics, filters, sort)
    
    results = {}
    data.to_h['points'].each do |entry|
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
  
  def get_data_by_date_and_path(start_date, end_date, dimensions, metrics, filters, sort)
    
    dimensions =  ['date', 'pagePath'] + dimensions
    data = get_data(start_date, end_date, dimensions, metrics, filters, sort)
    
    results = {}
    data.to_h['points'].each do |entry|
      entry_hash = entry.to_h
      next if entry_hash['dimensions'][1].blank? || entry_hash['dimensions'][1][:pagePath].blank? #skip the 'summary' (non-pagepath-specific) results
      entry_date = entry_hash['dimensions'][0][:date]
      entry_path = entry_hash['dimensions'][1][:pagePath]
      entry_metrics = entry_hash['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
      results[entry_date] = {} if results[entry_date].blank?
      results[entry_date][entry_path] = entry_metrics
    end
    
    #fill in any missing data with zeros
    Array(start_date..end_date).each do |date|
      date_string = date.to_s(:yyyymmdd)
      results[date_string] = {} if results[date_string].blank?
    end
    
    results
  end
  
  def get_data_by_path(start_date, end_date, dimensions, metrics, filters, sort)
    
    dimensions =  ['pagePath'] + dimensions
    data = get_data(start_date, end_date, dimensions, metrics, filters, sort)
    
    results = {}
    data.to_h['points'].each do |entry|
      entry_hash = entry.to_h
      entry_path = entry_hash['dimensions'][0][:pagePath]
      entry_metrics = entry_hash['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
      results[entry_path] = entry_metrics
    end
    
    results
  end
  
  def get_data_by_user(start_date, end_date, dimensions, metrics, filters, sort)
    
    dimensions =  ['customVarValue1'] + dimensions
    data = get_data(start_date, end_date, dimensions, metrics, filters, sort)
    
    results = {}
    
    data.to_h['points'].each do |entry|
      entry_user_id = entry.to_h['dimensions'].first[:customVarValue1]
      entry_metrics = entry.to_h['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
      results[entry_user_id] = entry_metrics
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
