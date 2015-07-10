module CustomPathHelper
  # just infers the standard rails show path helper
  def duck_path(object)
    if object.is_a? NilClass
      ""
    else
      send(
        "#{object.class.name.underscore}_path",
        object
      )
    end
  end

  # infers what we ACTUALLY problably want when we want to 'see' a given record
  def smart_duck_path(object)
    if object.is_a?(ReviewItem)
      if object.active?
        review_path(object)
      else
        rereview_path(object)
      end
    elsif object.is_a?(FeedbackItem)
      if object.active?
        feedback_items_path
      else
        archived_feedback_items_path
      end
    elsif object.is_a?(ReferralForm)
      edit_referral_forms_path(
        parent_type: object.referrable_type,
        parent_id: object.referrable_id
      )
    else
      duck_path(object)
    end
  end
end
