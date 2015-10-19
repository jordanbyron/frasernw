module WebUsageReport
  def self.exec(month, division, record_type)
    self.
      get_views(month, division, record_type).
      exec(args).
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
    }.merge(self.query_filters(division))).filter do |row|
      PATH_TESTS[record_type].call(row[:path])
    end.map do |row|
      row.merge(klass: PATH_KLASSES[record_type])
    end
  end

  def self.query_filters(division)
    if division == 0
      {}
    else
      { division_id: division }
    end
  end

  PATH_TESTS = {
    clinics: Proc.new{ |path| /\/clinics\/[[:digit:]]+\//.include?(path) },
    specialists: Proc.new{ |path| /\/specialists\/[[:digit:]]+\//.include?(path) },
    patient_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    physician_resources: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    forms: Proc.new{ |path| /\/content_items\/[[:digit:]]+\//.include?(path) },
    specialties: Proc.new{ |path| /\/specialties\/[[:digit:]]+\//.include?(path) },
  }
  PATH_KLASSES = {
    clinics: Clinic,
    specialists: Specialist,
    patient_resources: ScItem,
    physician_resources: ScItem,
    forms: ScItem,
    specialties: Specialization,
  }
end
