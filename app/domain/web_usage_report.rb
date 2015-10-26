class WebUsageReport
  include ServiceObject.exec_with_args(:month_key, :division_id, :record_type)
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
      link: link_to(*LABEL_SERIALIZED_COLLECTIONS[row[:serialized_collection]].call(row)),
      usage: row[:usage]
    }
  end

  LABEL_SERIALIZED_COLLECTIONS = {
    clinics: Proc.new do |row|
      [ row[:record][:name], "/clinics/#{row[:record][:id]}" ]
    end,
    specialists: Proc.new do |row|
      [ row[:record][:name], "/specialists/#{row[:record][:id]}" ]
    end,
    content_items: Proc.new do |row|
      [ row[:record][:title], "/content_items/#{row[:record][:id]}" ]
    end,
    referral_forms: Proc.new do |row|
      [ row[:record][:filename], "/#{row[:record][:referrableType].pluralize.downcase}/#{row[:record][:referrableId]}" ]
    end,
    specializations: Proc.new do |row|
      [ row[:record][:name], "/specialties/#{row[:record][:id]}" ]
    end
  }

  def get_usage
    (get_usage_from_page_views +
      get_usage_from_events).reduce([]) do |memo, row|
        existing_row = memo.find do |existing_row|
          row[:record][:id] == existing_row[:record][:id] &&
            row[:serialized_collection] == existing_row[:serialized_collection]
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
      filter_literal: filter_literals(division_filters(division_id))
    }).map do |row|
      {
        id: extract_id(record_type, row[:page_path]),
        serialized_collection: PAGE_VIEW_SERIALIZED_COLLECTIONS[record_type],
        usage: row[:page_views]
      }
    end.select do |row|
      row[:id].present?
    end.sort_by do |row|
      row[:usage].to_i
    end.map do |row|
      row.merge({
        record: safe_find(row[:serialized_collection], row[:id].to_i)
      })
    end.select do |row|
      row[:record].present? && PAGE_VIEW_FILTERS[record_type].call(row)
    end
  end

  def get_usage_from_events
    Analytics::ApiAdapter.get({
      metrics: [:total_events],
      start_date: Month.from_i(month_key).start_date,
      end_date: Month.from_i(month_key).end_date,
      dimensions: [:event_category, :event_label],
      filter_literal: filter_literals(division_filters(division_id).merge({ event_action: "clicked_link" }))
    }).map do |row|
      {
        id: row[:event_label],
        usage: row[:total_events],
        serialized_collection: EVENT_CATEGORY_SERIALIZED_COLLECTIONS[row[:event_category]]
      }
    end.select do |row|
      row[:serialized_collection].present?
    end.map do |row|
      row.merge(record: safe_find(row[:serialized_collection], row[:id].to_i))
    end.select do |row|
      row[:record].present? && EVENTS_FILTERS[record_type].call(row)
    end
  end

  # do we use event count from this row in our usage calculations?
  EVENTS_FILTERS = {
    clinics: Proc.new{ |row| false },
    specialists: Proc.new{ |row| false },
    patient_info: Proc.new do |row|
      !row[:record][:content].present? && row[:record][:categoryIds].include?(5)
    end,
    physician_resources: Proc.new do |row|
      !row[:record][:content].present? && row[:record][:categoryIds].include?(11)
    end,
    forms: Proc.new do |row|
      (row[:serialized_collection] == :content_items && !row[:record][:content].present? && row[:record][:categoryIds].include?(9)) ||
        row[:serialized_collection] == :referral_forms
    end,
    specialties: Proc.new{ |row| false }
  }

  #  which event categories respond to which class of record
  # (see analytics_wrappers.js)
  EVENT_CATEGORY_SERIALIZED_COLLECTIONS = {
    "form" => :referral_forms,
    "content_item" => :content_items
  }

  def safe_find(collection, id)
    all_records(collection)[id]
  end

  def all_records(collection)
    @all_records ||= Hash.new do |h, key|
      h[key] = Serialized.fetch(collection)
    end
    @all_records[collection]
  end

  def filter_literals(equality_filters)
    [
      Analytics::ApiAdapter.format_filters(equality_filters, "=="),
      Analytics::ApiAdapter.format_filters({user_type_key: "-1"}, "!="),
      Analytics::ApiAdapter.format_filters({user_type_key: "0"}, "!=")
    ].select(&:present?).join(";")
  end

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
    patient_info: Proc.new do |row|
      row[:record][:content].present? && row[:record][:categoryIds].include?(5)
    end,
    physician_resources: Proc.new do |row|
      row[:record][:content].present? && row[:record][:categoryIds].include?(11)
    end,
    forms: Proc.new do |row|
      row[:record][:content].present? && row[:record][:categoryIds].include?(9)
    end,
    specialties: Proc.new{ |row| true }
  }

  def extract_id(record_type, path)
    collection_path = {
      clinics: "clinics",
      specialists: "specialists",
      patient_info: "content_items",
      physician_resources: "content_items",
      forms: "content_items",
      specialties: "specialties"
    }[record_type]

    /(?<=\/#{Regexp.quote(collection_path)}\/)[[:digit:]]+/.match(path).to_s
  end

  # when we extract an ID from a path according to the tests above,
  # what serialized collection does it refer to?
  PAGE_VIEW_SERIALIZED_COLLECTIONS = {
    clinics: :clinics,
    specialists: :specialists,
    patient_info: :content_items,
    physician_resources: :content_items,
    forms: :content_items,
    specialties: :specializations
  }
end
