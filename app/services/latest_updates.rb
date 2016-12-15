class LatestUpdates < ServiceObject
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :force_automatic, Axiom::Types::Boolean, default: false
  attribute :division_ids, Array
  attribute :context, Symbol

  def self.recache_for_groups(division_id_groups, force_automatic: false)
    # we only want to regenerate automatic events once per division, so we
    # do it separately, first
    if force_automatic
      division_id_groups.flatten.uniq.each do |id|
        self.division_automatic_events(Division.find(id), force: true)
      end
    end

    division_id_groups.each do |group|
      CONTEXTS.each do |context|
        call(
          context: context,
          division_ids: group,
          force: true,
          force_automatic: false
        )
      end
    end
  end

  def call
    Rails.cache.fetch(
      "latest_updates:#{division_ids.sort.join('_')}:#{context}",
      force: force
    ) do
      (manual_events + automatic_events).
        sort_by{ |event| [ event[:date].to_s, event[:markup] ] }.
        each_with_index.
        map{|event, index| event.merge(index: index)}.
        reverse.
        uniq
    end
  end

  private

  CONTEXTS = [
    :front,
    :index
  ]

  def divisions
    @divisions ||= Division.find(division_ids)
  end

  def manual_events
    if only_current_manual_events
      NewsItem.current
    else
      NewsItem
    end.
      specialist_clinic_in_divisions(divisions).
      inject([]) do |memo, news_item|
        if news_item.title.present?
          memo << {
            markup: BlueCloth.
              new("#{news_item.title}. #{news_item.body}").
              to_html.html_safe,
            manual: true,
            hidden: false,
            date: (news_item.start_date || news_item.end_date)
          }
        else
          memo << {
            markup: BlueCloth.new(news_item.body).to_html.html_safe,
            manual: true,
            hidden: false,
            date: (news_item.start_date || news_item.end_date)
          }
        end
      end
  end

  def automatic_events
    returning = divisions.inject([]) do |memo, division|
      memo + LatestUpdates.division_automatic_events(
        division,
        force: force_automatic
      )
    end.map do |event|
      event.merge(hidden: LatestUpdatesMask.exists?(event.except(:markup)))
    end.group_by do |event|
      [ event[:item_type], event[:item_id], event[:event] ]
    end.map do |k, v|
        v[0].merge(hidden: v.any?{|event| event[:hidden] }, manual: false)
    end.
      sort_by{ |event| event[:date].to_s }.
      reverse

    if !show_hidden
      returning = returning.select{ |event| !event[:hidden] }
    end

    returning.take(max_automatic_events)
  end

  def max_automatic_events
    case context
    when :front
      5
    when :index
      100000
    end
  end

  def only_current_manual_events
    context == :front
  end

  def show_hidden
    context == :index
  end

  def self.event_code(event)
    LatestUpdatesMask::EVENTS.key(event)
  end
end
