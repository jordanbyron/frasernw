module WebUsageReport
  def self.exec(month, division, record_type)
    self.
      get_usage(month, division, record_type).
      sort_by{ |row| row[:views] }.
      first(20).
      map{|row| self.transform_row_for_view(row)}
  end

  private

  def self.transform_row_for_view(row)

  end

  def self.get_usage(month_key, division, record_type)
    (get_usage_from_page_views(month_key, division, record_type) +
      get_usage_from_events(month_key, division, record_type)).reduce([]) do |memo, row|
        existing_row = memo.find do |existing_row|
          row[:id] == existing_row[:id] &&
          row[:klass] == existing_row[:klass]
        end

        if existing_row.present?
          existing_row[:usage] += row[:usage]

          memo
        else
          memo << row
        end
      end
  end

  def self.get_usage_from_page_views(month_key, division, record_type)
    Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: Month.from_i(month_key).start_date,
      end_date: Month.from_i(month_key).end_date,
      dimensions: [ :page_path ]
    }.merge(self.page_view_query_filters(division))).filter do |row|
      RECORD_TYPE_PATH_TESTS[record_type].call(row[:path])
    end.map do |row|
      {
        record: PAGE_VIEW_KLASSES[record_type].find(RECORD_TYPE_PATH_TESTS[record_type].call(row[:path])),
        usage: row[:page_views],
        klass: PAGE_VIEW_KLASSES[record_type]
      }
    end.filter(PAGE_VIEW_FILTERS[record_type])
  end

  def self.get_usage_from_page_views(month_key, division, record_type)
    query.map do |row|
      {
        record: PAGE_VIEW_KLASSES[record_type].find(RECORD_TYPE_PATH_TESTS[record_type].call(row[:path])),
        usage: row[:page_views],
        klass: PAGE_VIEW_KLASSES[record_type]
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

  def self.event_query_filters(division)
    base = { event_category: "forms" }
    if division == 0
      {}
    else
      { division_id: division }
    end
  end

  # do we use the page views from this row in our usage calculations?
  PAGE_VIEW_FILTERS {
    clinics: Proc.new{ |record| true },
    specialists: Proc.new{ |record| true },
    patient_resources: Proc.new do |record|
      record.inline_content? && record.in_category?("Patient Info")
    end,
    physician_resources: Proc.new do |record|
      record.inline_content? && record.in_category?("Physician Resources")
    end,
    forms: Proc.new do |record|
      record.inline_content? && record.in_category?("Forms")
    end,
    specialties: Proc.new{ |record| true },
  }

  # how to extract record ID from a path
  RECORD_TYPE_PATH_TESTS = {
    clinics: Proc.new{ |path| /\/clinics\/[[:digit:]]+\//.include?(path) },
    specialists: Proc.new{ |path| /\/specialists\/[[:digit:]]+\//.include?(path) },
    patient_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    physician_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    forms: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    specialties: Proc.new{ |path| /\/specialties\/[[:digit:]]+\//.include?(path) },
  }

  # when we extract an ID from a path according to the tests above,
  # what klass does it refer to?
  PAGE_VIEW_KLASSES = {
    clinics: Clinic,
    specialists: Specialist,
    patient_resources: ScItem,
    physician_resources: ScItem,
    forms: ScItem,
    specialties: Specialization,
  }
end
