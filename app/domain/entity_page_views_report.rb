class EntityPageViewsReport < ServiceObject
  attribute :start_month_key
  attribute :end_month_key
  attribute :division_id
  attribute :record_type

  include ActionView::Helpers::UrlHelper


  def call
    EntityPageViews.call(
      start_month_key: start_month_key,
      end_month_key: end_month_key,
      division_id: division_id.to_i
    ).select do |row|
      case record_type
      when :forms
        (row[:resource] == :content_items && matching_sc_items.include?(row[:id])) ||
          row[:resource] == :referral_forms
      when :patient_info, :physician_resources, :red_flags, :community_services, :pearls
        row[:resource] == :content_items && matching_sc_items.include?(row[:id])
      else
        row[:resource] == record_type
      end
    end.inject([]) do |memo, row|
      denormalized_collection =
        if row[:resource] == :specialties
          :specializations
        else
          row[:resource]
        end
      denormalized_record = find_denormalized_record(denormalized_collection, row[:id])

      next memo if denormalized_record.nil?

      label = case row[:resource]
        when :content_items
          denormalized_record[:title]
        when :referral_forms
          denormalized_record[:label]
        else
          denormalized_record[:name]
        end

      url = case row[:resource]
        when :referral_forms
          "/#{denormalized_record[:referrableType].pluralize.downcase}"\
            "/#{denormalized_record[:referrableId]}"
        else
          "/#{row[:resource]}/#{row[:id]}"
        end


      memo << {
        link: link_to(label, url),
        usage: row[:page_views],
        label: label,
        collectionName: "#{row[:serialized_collection]}pageViewData",
        id: row[:id]
      }
    end.sort_by{ |row| [ row[:usage], row[:label] ] }.reverse()
  end

  private

  def matching_sc_items
    @matching_sc_items ||= ScCategory.find_by(
      name: record_type.to_s.split("_").map(&:capitalize).join(" ")
    ).subtree.map(&:sc_items).flatten.uniq.map(&:id)
  end

  def find_denormalized_record(denormalized_collection, id)
    @denormalized_records ||= Hash.new do |hsh, key|
      hsh[key] = Denormalized.fetch(key)
    end

    @denormalized_records[denormalized_collection][id]
  end
end
