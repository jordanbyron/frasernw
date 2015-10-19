module WebUsageReport
  def self.exec(month, division, record_type)
    self.
      get_views(month, division, record_type).
      sort_by{ |row| row[:views] }.
      first(20).
      map{|row| self.create_row(row)}
  end

  private

  def self.create_row(row)

  end

  def self.get_views(month_key, division, record_type)
    get_views_from_page_views(month_key, division, record_type) +
      get_views_from_events
  end

  def self.get_views_from_page_views(month_key, division, record_type)
    Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: Month.from_i(month_key).start_date,
      end_date: Month.from_i(month_key).end_date,
      dimensions: [ :page_path ]
    }.merge(self.page_view_query_filters(division))).filter do |row|
      RECORD_TYPE_PATH_TESTS[record_type].call(row[:path])
    end.map do |row|
      {
        record: RECORD_TYPE_KLASSES[record_type].find(RECORD_TYPE_PATH_TESTS[record_type].call(row[:path])),
        views: row[:page_views]
      }
    end.filter(PAGE_VIEW_FILTERS[record_type])
  end

  def self.page_view_query_filters(division)
    if division == 0
      {}
    else
      { division_id: division }
    end
  end

  # do we get their usage statistics from page views?
  PAGE_VIEW_FILTERS {
    clinics: Proc.new{ |record| true },
    specialists: Proc.new{ |record| true },
    patient_resources: Proc.new{ |record| record.inline_content? },
    physician_resources: Proc.new{ |record| record.inline_content? },
    forms: Proc.new do |record|
      if record.is_a?(ScItem)
        !record.inline_content?
      else
        true
      end
    end,
    specialties: Proc.new{ |record| true },
  }

  RECORD_TYPE_PATH_TESTS = {
    clinics: Proc.new{ |path| /\/clinics\/[[:digit:]]+\//.include?(path) },
    specialists: Proc.new{ |path| /\/specialists\/[[:digit:]]+\//.include?(path) },
    patient_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    physician_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    forms: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    specialties: Proc.new{ |path| /\/specialties\/[[:digit:]]+\//.include?(path) },
  }
  RECORD_TYPE_KLASSES = {
    clinics: Clinic,
    specialists: Specialist,
    patient_resources: ScItem,
    physician_resources: ScItem,
    forms: ScItem,
    specialties: Specialization,
  }
end
