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

  # def self.collect_activities(date, classification, divisions, type_mask_integer)
  #   self.includes(:trackable).created_at(date).by_update_classification(classification).by_divisions(divisions).by_type_mask(type_mask_integer).reverse
  # end

  def self.collect_activities(*args)
    # # Methods for defining / handling incoming *args.
    options = args.extract_options!
    subscription      = options[:subscription]
    date              = options[:date]                        || (subscription.interval_to_datetime        if subscription.present?)
    classification    = options[:classification]              || (subscription.classification              if subscription.present?)
    divisions         = options[:divisions]                   || (subscription.divisions                   if subscription.present?)
    type_mask_integer = options[:type_mask_integer]           || (subscription.news_type_masks             if subscription.present?)
    format_type       = options[:format_type_integer]         || (subscription.sc_item_format_type_masks   if subscription.present?)
    specializations   = options[:specializations]             || (subscription.specializations             if (subscription.present? && subscription.specializations.present?))
    sc_categories     = options[:sc_categories]               || (subscription.sc_categories               if (subscription.present? && subscription.sc_categories.present?))

    # wrap them as arrays in case option is used
    divisions = Array.wrap(divisions)
    specializations = Array.wrap(specializations)
    sc_categories = Array.wrap(sc_categories)


    @arr = Array.new
    if specializations.present? # added for performance boost, tough due to trackable Single Table Inheritance
      # @activities = self.includes(:trackable => [:specializations]).created_at(date).by_update_classification(classification).by_divisions(divisions).by_type_mask(type_mask_integer).by_format_type(format_type).by_specializations(specializations).reverse
      @activities = self.includes(:trackable => [:specializations]).created_at(date).by_update_classification(classification).by_divisions(divisions).by_type_mask(type_mask_integer).by_specializations(specializations).reverse

    else
      @activities = self.includes(:trackable).created_at(date).by_update_classification(classification).by_divisions(divisions).by_type_mask(type_mask_integer).by_format_type(format_type).by_specializations(specializations).reverse
    end
    @arr << @activities

    if specializations.present?
      # Much faster but needs testing:
      # @spec_activities = @activities.reject{|a| a if (!a.trackable.present? || (a.trackable.specializations & specializations).blank?)}
      @spec_activities = @activities.map(&:trackable).reject{|trackable| trackable == nil} # convert to tracked_objects
                               .reject{|trackable| (trackable.specializations & specializations).blank?} # compare tracked_object's specializations with given specializations
                               .map{ |trackable| trackable.activities if trackable.activities.present?} # return activity objects with matching specializations
      @spec_activities.flatten! if @spec_activities.present? # if specializations present but not found we want to return [] for @arr.reduce method below to filter out all activities
      @arr << @spec_activities
    end
    if sc_categories.present? # convert to tracked_objects, compare tracked_object's ***ROOT*** sc_category categories with sc_categories, return in @sc_activity activity objects with matching sc_category roots
      @activities.reject!{|a| a.update_classification_type == Subscription.news_update} #make sure no news update activities exist
      @sc_activities = @activities.map(&:trackable).reject{|t| t == nil}.reject{|t| !sc_categories.include?(t.root_category) }.map{|t| t.activities if t.activities.present?}
      @sc_activities.flatten! if @spec_activities.present? # if sc_categories present but not found, otherwise we want to return [] for @arr.reduce method below to filter out all activities
      @arr << @sc_activities
    end
    return @arr.reduce(:&) # runs an & operation against total array for each @arr element present, e.g.: (@activities & @sc_activities & @spec_activities) or (@activities & @sc_activities)
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