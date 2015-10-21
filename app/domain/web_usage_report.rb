class WebUsageReport
  include ServiceObject.exec_with_args(:month_key, :division_id, :record_type)

  include CustomPathHelper
  include ActionView::Helpers::UrlHelper

  def exec
    get_usage.
      sort_by{ |row| row[:usage].to_i }.
      reverse().
      first(20).
      map{|row| transform_row_for_view(row)}
  end

  private

  def transform_row_for_view(row)
    {
      link: link_to(row[:record].name, smart_duck_path(row[:record])),
      usage: row[:usage]
    }
  end

  def get_usage
    (get_usage_from_page_views +
      get_usage_from_events).reduce([]) do |memo, row|
        existing_row = memo.find do |existing_row|
          row[:record] == existing_row[:record] &&
            row[:klass] == existing_row[:klass]
        end

        if existing_row.present?
          existing_row[:usage] = existing_row[:usage].to_i + row[:usage].to_i

          memo
        else
          memo << row
        end
      end
  end

  def get_usage_from_page_views
    Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: Month.from_i(month_key).start_date,
      end_date: Month.from_i(month_key).end_date,
      dimensions: [ :page_path ],
      filters: division_filters(division_id)
    }).select do |row|
      extract_id(record_type, row[:page_path]).present? &&
        PAGE_VIEW_KLASSES[record_type].safe_find(extract_id(record_type, row[:page_path])).present?
    end.map do |row|
      {
        record: PAGE_VIEW_KLASSES[record_type].find(extract_id(record_type, row[:page_path])),
        usage: row[:page_views],
        klass: PAGE_VIEW_KLASSES[record_type]
      }
    end.select(&PAGE_VIEW_FILTERS[record_type])
  end

  def get_usage_from_events
    Analytics::ApiAdapter.get({
      metrics: [:total_events],
      start_date: Month.from_i(month_key).start_date,
      end_date: Month.from_i(month_key).end_date,
      dimensions: [:event_category, :event_label],
      filters: division_filters(division_id).merge({ event_action: "clicked_link" })
    }).select do |row|
      EVENT_CATEGORY_KLASSES.keys.include?(row[:event_category]) &&
        EVENT_CATEGORY_KLASSES[row[:event_category]].safe_find(row[:event_label]).present?
    end.map do |row|
      {
        record: EVENT_CATEGORY_KLASSES[row[:event_category]].find(row[:event_label]),
        usage: row[:total_events],
        klass: EVENT_CATEGORY_KLASSES[row[:event_category]]
      }
    end.select(&EVENT_TYPE_FILTERS[record_type])
  end

  # do we use the page views from this row in our usage calculations?
  EVENT_TYPE_FILTERS = {
    clinics: Proc.new{ |row| false },
    specialists: Proc.new{ |row| false },
    patient_resources: Proc.new do |row|
      !row[:record].inline_content? && row[:record].in_category?("Patient Info")
    end,
    physician_resources: Proc.new do |row|
      !row[:record].inline_content? && row[:record].in_category?("Physician Resources")
    end,
    forms: Proc.new do |row|
      (row[:klass] == ScItem && !row[:record].inline_content? && row[:record].in_category?("Forms")) ||
        row[:klass] == Form
    end,
    specialties: Proc.new{ |row| false },
  }

  #  which event categories respond to which class of record
  # (see analytics_wrappers.js)
  EVENT_CATEGORY_KLASSES = {
    "form" => ReferralForm,
    "content_item" => ScItem
  }

  def division_filters(division)
    if division == "0"
      {}
    else
      { division_id: division }
    end
  end

  # do we use the page views from this row in our usage calculations?
  PAGE_VIEW_FILTERS = {
    clinics: Proc.new{ |row| true },
    specialists: Proc.new{ |row| true },
    patient_resources: Proc.new do |row|
      row[:record].inline_content? && row[:record].in_category?("Patient Info")
    end,
    physician_resources: Proc.new do |row|
      row[:record].inline_content? && row[:record].in_category?("Physician Resources")
    end,
    forms: Proc.new do |row|
      row[:record].inline_content? && row[:record].in_category?("Forms")
    end,
    specialties: Proc.new{ |row| true }
  }

  def extract_id(record_type, path)
    collection_path = {
      clinics: "clinics",
      specialists: "specialists",
      patient_resources: "content_items",
      physician_resources: "content_items",
      forms: "content_items",
      specialties: "specialties"
    }[record_type]

    /(?<=\/#{Regexp.quote(collection_path)}\/)[[:digit:]]+/.match(path).to_s
  end

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
