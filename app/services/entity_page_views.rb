class EntityPageViews < ServiceObject
  attribute :start_month_key
  attribute :end_month_key
  attribute :division_id

  def call
    return [] if start_month > end_month

    usage_from_page_views + usage_from_events
  end

  def start_month
    @start_month ||= Month.from_i(start_month_key)
  end

  def end_month
    @end_month ||= Month.from_i(end_month_key)
  end

  def usage_from_page_views
    Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: start_month.start_date,
      end_date: end_month.end_date,
      dimensions: [ :page_path ],
      filter_literal: filter_literals(division_filters)
    }).inject([]) do |memo, row|
      show_page_routing = /\/(\w+)\/([[:digit:]]+)(?:\/\z|\?|\z)/.match(row[:page_path])
      next memo if show_page_routing.nil?

      resource = show_page_routing[1].to_sym
      id = show_page_routing[2].to_i

      next memo unless record_exists?(resource, id)
      next memo if resource == :content_items && !markdown_ids.include?(id)

      memo << {
        resource: resource,
        id: id,
        page_views: row[:page_views].to_i
      }
    end
  end

  def usage_from_events
    Analytics::ApiAdapter.get({
      metrics: [:total_events],
      start_date: Month.from_i(start_month_key).start_date,
      end_date: Month.from_i(end_month_key).end_date,
      dimensions: [:event_category, :event_label],
      filter_literal: filter_literals(
        division_filters.merge({ event_action: "clicked_link" })
      )
    }).inject([]) do |memo, row|
      resource = case row[:event_category]
        when "forms"
          :referral_forms
        when "content_items"
          :content_items
        end
      id = row[:event_label].to_i

      next memo unless record_exists?(resource, id)
      next memo if resource == :content_items && markdown_ids.include?(id)

      memo << {
        resource: resource,
        id: id,
        page_views: row[:total_events].to_i
      }
    end
  end

  def markdown_ids
    @markdown_ids ||= ScItem.where(type_mask: ScItem::TYPE_MARKDOWN).pluck(:id)
  end

  def record_exists?(resource, id)
    @resource_ids ||= Hash.new do |hsh, key|
      hsh[key] = RESOURCE_MODELS[key].pluck(:id)
    end

    if RESOURCE_MODELS.has_key?(resource)
      @resource_ids[resource].include?(id)
    else
      false
    end
  end

  RESOURCE_MODELS = {
    areas_of_practice: Procedure,
    content_items: ScItem,
    specialists: Specialist,
    clinics: Clinic,
    referral_forms: ReferralForm,
    content_categories: ScCategory,
    specialties: Specialization
  }

  def filter_literals(equality_filters)
    [
      Analytics::ApiAdapter.format_filters(equality_filters, "=="),
      Analytics::ApiAdapter.format_filters({user_type_key: "-1"}, "!="),
      Analytics::ApiAdapter.format_filters({user_type_key: "0"}, "!=")
    ].select(&:present?).join(";")
  end

  def division_filters
    if division_id == 0
      {}
    else
      { division_id: division_id.to_s }
    end
  end
end
