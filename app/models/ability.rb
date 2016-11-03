class Ability
  include CanCan::Ability

  def initialize(user)
    can [:new, :create], FeedbackItem
    can :notify, :notifications

    if !user.authenticated?
      can [:validate, :signup, :setup], User

    elsif user.as_introspective?
      can [
        :index_own,
        :show,
        :edit,
        :update,
        :print_location_information
      ], Clinic do |clinic|
        !clinic.hidden? && clinic.controlling_users.include?(user)
      end

      can :index, ReferralForm

      can :show, FaqCategory
      can :terms_and_conditions, :static_pages
      can [:index, :show], Video

      can [
        :change_email,
        :update_email,
        :change_password,
        :update_password
      ], User

    else
      can [:index], :front
      can :show, FaqCategory
      can :terms_and_conditions, :static_pages
      can :get, :global_data
      can :index, Newsletter
      can [:index, :show], Video

      can :index, :latest_updates

      if user.as_super_admin?
        can :manage, :all
        can :show, :analytics

      elsif user.as_admin?
        can :view_report, [
          :page_views,
          :sessions,
          :csv_usage,
          :referents_by_specialty,
          :entity_page_views,
          :user_ids,
          :archived_feedback_items,
          :change_requests
        ]

        can [:show, :toggle_subscription], Issue
        can [:index, :show], :change_requests

        can :index, :reports

        can :manage, SecretToken

        can :manage, FeaturedContent

        can :manage, DivisionalScItemSubscription do |subscription|
          user.as_divisions.include?(subscription.division)
        end

        can :manage, [Subscription, Notification]

        can :manage, [Specialist, Clinic, Hospital, Office] do |entity|
          entity.divisions.blank? ||
            (entity.divisions & user.as_divisions).present?
        end
        cannot :destroy, [Specialist, Clinic, Evidence]
        can :create, [Specialist, Clinic, Hospital, Office]

        can :read, Evidence

        can :manage, Version

        can [:index, :edit, :update], Specialization

        #so that an admin can list offices by city for those in their division
        can :read, City do |city|
          (city.divisions & user.as_divisions).present?
        end
        #admin can not list all cities, though
        cannot :index, City

        can :manage, ScItem do |item|
          user.as_divisions.include? item.division
        end
        can [:create, :bulk_borrow], ScItem

        can :borrow, ScItem do |item|
          item.borrowable
        end

        can :manage, DivisionDisplayScItem do |item|
          user.as_divisions.include? Division.find(item.division_id)
        end

        #can edit non-admin/super-admin users
        can [:index, :new, :create, :show], User
        can [:edit, :update, :destroy], User do |target_user|
          !target_user.super_admin? &&
            (target_user.divisions & user.as_divisions).present?
        end
        can [
          :change_email,
          :update_email,
          :change_password,
          :update_password
        ], User

        can [:index, :new, :create, :show, :copy], NewsItem
        can [:edit, :update], NewsItem do |news_item|
          user.as_divisions.include? news_item.owner_division
        end

        can [:show, :edit, :update, :hide_updates], Division do |division|
          user.as_divisions.include? division
        end

        can :manage, FeedbackItem do |feedback_item|
          (feedback_item.owner_divisions & user.as_divisions).any?
        end

        can :manage, ReviewItem do |review_item|
          review_item.item.present? && (
            (
              review_item.item.instance_of?(Specialist) &&
              (review_item.item.divisions & user.as_divisions).present?
            ) || (
              review_item.item.instance_of?(Clinic) &&
              (review_item.item.divisions & user.as_divisions).present?
            )
          )
        end

        #landing page, per-division restrictions are handled in controller
        can :manage, FeaturedContent

        #can show pages, regardless of 'in progress'
        can :show, [
          Specialization,
          Procedure,
          Hospital,
          Language,
          ScCategory,
          Specialist,
          Clinic,
          ScItem
        ]

        can :city, Specialization

        can [:print_office_information, :print_clinic_information], Specialist
        can [:print_location_information], Clinic

        can :index, ReferralForm

        can [
          :change_email,
          :update_email,
          :change_password,
          :update_password
        ], User

        can :index, Notification

        can :manage, Subscription

        can [:create], Note
        can :destroy, Note do |note|
          note.user == user
        end

        can :view_history, Historical

      elsif user.as_user?
        can :show, [Specialist, Clinic] do |entity|
          !entity.hidden? ||
            entity.controlling_users.include?(user)
        end

        can :show, [ Specialization, Procedure ]

        can :show, ScItem do |item|
          item.available_to_divisions?(user.as_divisions)
        end

        can :show, [Hospital, Language, ScCategory]

        can [:print_office_information, :print_clinic_information], Specialist
        can [:print_location_information], Clinic

        can :index, ReferralForm

        can [
          :change_email,
          :update_email,
          :change_password,
          :update_password
        ], User

        can [:update, :photo, :update_photo], Specialist do |specialist|
          specialist.controlling_users.include? user
        end

        can :update, Clinic do |clinic|
          clinic.controlling_users.include? user
        end

      end

      # No one can update items that need review unless they made the review.
      cannot :update, Specialist do |specialist|
        specialist.review_item.present? &&
          specialist.review_item.editor != user
      end

      cannot :update, Clinic do |clinic|
        clinic.review_item.present? && clinic.review_item.editor != user
      end

    end
  end
end
