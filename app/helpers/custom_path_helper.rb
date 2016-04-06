module CustomPathHelper
  ROUTES = Rails.application.routes.url_helpers

  # just infers the standard rails show path helper
  def self.duck_path(object)
    if object.is_a? NilClass
      ""
    else
      ROUTES.send(
        "#{object.class.name.underscore}_path",
        object
      )
    end
  end

  # infers what we ACTUALLY problably want when we want to 'see' a given record
  def self.smart_duck_path(object)
    if object.is_a?(ReviewItem)
      if object.active?
        ReviewItemsHelper.review_path(object)
      else
        ReviewItemsHelper.rereview_path(object)
      end
    elsif object.is_a?(FeedbackItem)
      if object.active?
        ROUTES.feedback_items_path
      else
        ROUTES.archived_feedback_items_path
      end
    elsif object.is_a?(ReferralForm)
      ROUTES.edit_referral_forms_path(
        parent_type: object.referrable_type,
        parent_id: object.referrable_id
      )
    elsif object.is_a?(SecretToken)
      ""
    else
      self.duck_path(object)
    end
  end
end
