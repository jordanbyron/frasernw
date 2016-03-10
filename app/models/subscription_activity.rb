class SubscriptionActivity < PublicActivity::Activity

  def self.created_at(date)
    if date.present?
      where('created_at >= ?', date)
    else
      scoped
    end
  end

  def self.by_update_classification(classification)
    if classification.present?
      where(update_classification_type: classification)
    else
      scoped
    end
  end

  def self.by_divisions(divisions)
    if divisions.present?
      where('owner_type = ?', "Division").where(owner_id: divisions)
    else
      scoped
      # where('owner_type = ?', "Division").where(owner_id: "") # defaults to blank string to stop break in method chaining (e.g.: .all.all)
    end
  end

  def self.by_type_mask(type_mask_integer)
    if type_mask_integer.present?
      where(type_mask: type_mask_integer)
    else
      scoped
    end
  end

  def self.by_format_type(format_type_integer)
    if format_type_integer.present?
      where(format_type: format_type_integer)
    else
      scoped
    end
  end

  def self.by_specializations(specializations)
    if specializations.present?
      where(trackable_type: "ScItem" || "ScCategory").all
    else
      scoped
    end
  end

  def self.to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def self.collect_activities(*args)
    # # Methods for defining / handling incoming *args.
    options = args.extract_options!
    subscription      = options[:subscription]
    date              = options[:date]                        || (subscription.interval_to_datetime        if subscription.present?)
    classification    = options[:classification]              || (subscription.classification              if subscription.present?)
    divisions         = options[:divisions]                   || (subscription.divisions                   if subscription.present?)
    type_mask_integer = options[:type_mask_integer]           || (subscription.news_type_masks             if subscription.present?)
    format_type       = options[:format_type_integer]         || (subscription.sc_item_format_type_masks   if subscription.present?)
    sc_categories     = options[:sc_categories]               || (subscription.sc_categories               if (subscription.present? && subscription.sc_categories.present?))

    # wrap them as arrays in case option is used
    divisions = Array.wrap(divisions)
    sc_categories = Array.wrap(sc_categories)


    @result = []
    if subscription.specializations.any?
      @result = @result | self.
        includes(:trackable => [:specializations]).
        created_at(date).
        by_update_classification(classification).
        by_divisions(divisions).
        by_type_mask(type_mask_integer).
        by_specializations(specializations).
        reverse
    else
      @result = @result | self.
        includes(:trackable).
        created_at(date).
        by_update_classification(classification).
        by_divisions(divisions).
        by_type_mask(type_mask_integer).
        by_format_type(format_type).
        by_specializations(specializations).
        reverse
    end

    if subscription.specializations.any?
      @result = @result | @activities.
        map(&:trackable).
        reject(&:nil?).
        reject{|trackable| (trackable.specializations & specializations).blank? }.
        map{ |trackable| trackable.activities }.
        flatten
    end

    if sc_categories.present? # convert to tracked_objects, compare tracked_object's ***ROOT*** sc_category categories with sc_categories, return in @sc_activity activity objects with matching sc_category roots
      @sc_activities = @activities.
        select{ |activity| activity.update_classification_type == Subscription.resource_update }.
        map(&:trackable).
        reject(&:nil?).
        select{ |trackable| sc_categories.include?(trackable.root_category) }.
        map(&:activities).
        flatten
        
      @result = @result | @sc_activities
    end
    return @result.reduce(:&) # runs an & operation against total array for each @result element present, e.g.: (@activities & @sc_activities & @spec_activities) or (@activities & @sc_activities)
  end

  def self.all_resource_activities
    by_update_classification(Subscription.resource_update).all
  end

  def type_mask_description_formatted # helper to fix awkward language
    case
    when type_mask_description == "Markdown"
      "Markdown content" #e.g. "Markdown content" was just added ...
    when ["Breaking News"].include?(type_mask_description)
      type_mask_description #e.g. "Breaking News" was just added ...
    else
      type_mask_description.indefinitize # e.g. "an Attachment Update" was just added ...
    end
  end
end
