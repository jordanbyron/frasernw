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
    when Report::ReportType::PAGE_VIEWS
      
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
        filters << "customVarValue2!=0"
      elsif @report.user_type_mask == 0
        #everyone
      else
        #specific class
        dimensions << 'customVarValue2'
        filters << "customVarValue2 == #{@report.user_type_mask}"
      end
      
      results = get_data_by_date(start_date, end_date, dimensions, metrics, filters, sort)
      
      puts results
      
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
        user_results.each do |user_id, metrics|
          user = User.find_by_id(user_id)
          @user_results << [ user.name, metrics[:visits], metrics[:visitors], metrics[:pageviews] ] if user.present?
        end
      end
      
    when Report::ReportType::CONTENT_ITEMS
    
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
      markdown_ids = ScItem.markdown.reject{ |i| @report.only_shared_care && !i.shared_care }.map{ |c| c.id }
      inline_ids = ScItem.inline.map{ |c| c.id }
      
      Array(dates.first..dates.last).each_with_index do |date, date_index|
        date_string = date.to_s(:yyyymmdd)
        total_pageviews[date_index] = 0
        results_markdown[date_string].each do |path, metrics|
          next if !path.starts_with?('/content_items/')
          content_item_id = path.split('/').last.to_i
          next if !markdown_ids.include?(content_item_id)
          next if inline_ids.include?(content_item_id)
          total_pageviews[date_index] += metrics[:pageviews]
        end
      end
      if @report.by_pageview
        by_page_pageviews_map = {}
        Array(dates.first..dates.last).each do |date|
          date_string = date.to_s(:yyyymmdd)
          results_markdown[date_string].each do |path, metrics|
            next if !path.starts_with?('/content_items/')
            content_item_id = path.split('/').last.to_i
            next if !markdown_ids.include?(content_item_id)
            next if inline_ids.include?(content_item_id)
            if by_page_pageviews_map[content_item_id].present?
              by_page_pageviews_map[content_item_id] = [ by_page_pageviews_map[content_item_id][0], by_page_pageviews_map[content_item_id][1] + metrics[:pageviews] ]
            else
              content_item = ScItem.find_by_id(content_item_id)
              title = content_item.present? ? content_item.title : "[Deleted content item]"
              by_page_pageviews_map[content_item_id] = [ title, metrics[:pageviews] ]
            end
          end
        end
      end
      
      #grab the 'outgoing links' events, cobmine into results
      
      metrics = ['totalEvents']
      dimensions = ['date', 'eventCategory', 'eventAction', 'eventLabel']
      filters = ["eventCategory =@ content_item_id", "eventAction == #{ScItem::TYPE_LINK}"]
      sort = []
      
      if @report.user_type_mask == -1
        #non admin
        dimensions = ['customVarValue2'] + dimensions
        filters << "customVarValue2 != 0"
      elsif @report.user_type_mask == 0
        #everyone
      else
        #specific user class
        dimensions = ['customVarValue2'] + dimensions
        filters << "customVarValue2 == #{@report.user_type_mask}"
      end
      
      results_outgoing = get_data_by_dimensions(['date', 'eventAction', 'eventLabel'], start_date, end_date, dimensions, metrics, filters, sort)
      
      date_lookup = {}
      Array(dates.first..dates.last).each_with_index{ |date, date_index| date_lookup[date.to_s(:yyyymmdd)] = date_index }
      
      results_outgoing.each do |date, level1|
        date_index = date_lookup[date]
        level1.each do |action, level2|
          level2.each do |label, metrics|
            content_item_id = label.to_i
            next if inline_ids.include?(content_item_id)
            total_pageviews[date_index] += metrics[:totalEvents]
            if @report.by_pageview
              if by_page_pageviews_map[content_item_id].present?
                by_page_pageviews_map[content_item_id] = [ by_page_pageviews_map[content_item_id][0], by_page_pageviews_map[content_item_id][1] + metrics[:totalEvents] ]
              else
                content_item = ScItem.find_by_id(content_item_id)
                title = content_item.present? ? content_item.title : "[Deleted content item]"
                by_page_pageviews_map[content_item_id] = [ title, metrics[:totalEvents] ]
              end
            end
          end
        end
      end
      
      if @report.by_pageview
        by_pageviews_count = 0
        @by_page_pageviews = []
        ScItem.not_inline.each do |sc_item|
          if by_page_pageviews_map[sc_item.id].blank?
            @by_page_pageviews << [sc_item.title, 0]
          else
            @by_page_pageviews << by_page_pageviews_map[sc_item.id]
            by_pageviews_count += by_page_pageviews_map[sc_item.id][1]
          end
        end
        puts "!!!!!!!!!!!!!!!!!!!!! by_pageviews_count #{by_pageviews_count}"
      end
      
      total_pageviews_count = 0
      total_pageviews.each{ |t| total_pageviews_count += t }
      
      puts "!!!!!!!!!!!!!!!!!!!!! total_pageviews_count #{total_pageviews_count}"
      
      #Graph it
      
      @h = LazyHighCharts::HighChart.new('graph') do |f|
        f.options[:chart][:defaultSeriesType] = "area"
        f.options[:plotOptions] = {areaspline: {pointInterval: 1.day, pointStart: dates.first.day}}
        f.options[:xAxis][:categories] = Array(dates.first..dates.last)
        f.options[:xAxis][:labels] = {}
        f.options[:xAxis][:labels][:step] = 7
        f.series(:name => 'Pageviews', :data => total_pageviews)
      end
      when Report::ReportType::SPECIALIST_CONTACT_HISTORY
      @specialist_email_table = {}
      @divisions = @report.divisional? ? [@report.division] : Division.all
      Specialization.all.each do |s|
        next if s.fully_in_progress_for_divisions(divisions)
        specialization = []
        s.specialists.sort_by{ |sp| sp.locations.first.present? ? sp.locations.first.short_address : ""}.each do |sp|
          next if !sp.responded? || sp.not_available?
          active_controlling_users = sp.controlling_users.reject{ |u| u.pending? || !u.active? }
          entry = {}
          entry[:id] = sp.id
          entry[:name] = sp.name
          entry[:user_email] = active_controlling_users.map{ |u| u.email }.map{ |e| e.split }.flatten.reject{ |e| !(e.include? '@') }
          entry[:moa_email] = sp.contact_email.split.flatten.reject{ |e| !(e.include? '@') }
          entry[:token] = sp.token
          entry[:updated_at] = sp.updated_at
          review_item = sp.archived_review_items.sort_by{ |x| x.id }.last
          entry[:reviewed_at] = review_item.present? ? review_item.updated_at : nil
          entry[:linked_active_account_count] = active_controlling_users.count
          entry[:linked_pending_account_count] = sp.controlling_users.reject{ |u| !u.pending? }.count
          specialization << entry
        end
        @specialist_email_table[s.id] = specialization
      end
    when Report::ReportType::ENTITY_STATS
      @divisional = @report.divisional?
      @divisions = @report.divisional? ? [@report.division] : Division.all
      render :stats
    else
      @data = nil
    end
    
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def new
    @report = Report.new
    @ReportType = Report::ReportType
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
    @ReportType = Report::ReportType
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
      :sort => sort,
      :max_results => 10000
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
    result_count = 0
    data.to_h['points'].each do |entry|
      entry_hash = entry.to_h
      result_count += 1
      next if entry_hash['dimensions'][1].blank? || entry_hash['dimensions'][1][:pagePath].blank? #skip the 'summary' (non-pagepath-specific) results
      entry_date = entry_hash['dimensions'][0][:date]
      entry_path = entry_hash['dimensions'][1][:pagePath]
      entry_metrics = entry_hash['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
      results[entry_date] = {} if results[entry_date].blank?
      results[entry_date][entry_path] = entry_metrics
    end
    
    puts "!!!!!!!!!!!!!!!!!!!!!#{result_count}"
    
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
  
  def get_data_by_dimensions(dimension_to_get, start_date, end_date, dimensions, metrics, filters, sort)
    
    data = get_data(start_date, end_date, dimensions, metrics, filters, sort)
    dimension_symbols = dimensions.map{ |d| d.to_sym }
    
    results = {}
    data.to_h['points'].each do |entry|
      entry_hash = entry.to_h
      dimension_results = []
      cur_result = results
      dimensions.each_with_index do |dimension, index|
        next if !dimension_to_get.include?(dimension)
        dimension_results[index] = entry_hash['dimensions'][index][dimension_symbols[index]]
        if index == (dimensions.length - 1)
          #last dimension
          entry_metrics = entry_hash['metrics'].reduce({}) { |h, pairs| pairs.each { |k, v| h[k] = v }; h }
          if cur_result[dimension_results[index]].blank?
            cur_result[dimension_results[index]] = entry_metrics
          else
            entry_metrics.each do |k,v|
              cur_result[dimension_results[index]][k] += v
            end
          end
        else
          cur_result[dimension_results[index]] = {} if cur_result[dimension_results[index]].blank?
          cur_result = cur_result[dimension_results[index]]
        end
      end
    end
    
    puts results
    
    return results
  end
  
  def get_start_end_date(report)
    case report.time_frame_mask
      when Report::TimeFrame::YESTERDAY
        return [Date.today - 1, Date.today-1]
      when Report::TimeFrame::LAST_WEEK
        return [Date.today - 7, Date.today]
      when Report::TimeFrame::LAST_MONTH
        return [Date.today - 1.month, Date.today]
      when Report::TimeFrame::LAST_YEAR
        return [Date.today - 1.year, Date.today]
      when Report::TimeFrame::ALL_TIME
        return [Date.new(2012,06,1), Date.today]
      when Report::TimeFrame::CUSTOM_RANGE
        return [report.start_date, report.end_date]
      else
        return [Date.today - 1, Date.today]
      end
  end
end
