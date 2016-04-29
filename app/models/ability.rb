class Ability
  include CanCan::Ability

  def initialize(user)
    can [:new, :create], Message

    if !user.authenticated?
      can [:validate, :signup, :setup], User

    else
      can [:index], :front
      can :show, FaqCategory
      can :index, :terms_and_conditions
      can :get, :global_data
      can :index, Newsletter
      can :index, :latest_updates

      if user.as_super_admin?
        can :manage, :all
        can :show, :analytics

      elsif user.as_admin?
        can :view_report, :page_views
        can :view_report, :sessions
        can :view_report, :csv_usage
        can :view_report, :referents_by_specialty
        can :view_report, :usage
        can :view_report, :user_ids

        can :index, Report

        can :manage, SecretToken

        can :manage, FeaturedContent

        can :manage, [Subscription, Notification]

        can :manage, [Specialist, Clinic, Hospital, Office] do |entity|
          entity.divisions.blank? || (entity.divisions & user.as_divisions).present?
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
        can [:create, :bulk_share], ScItem

        can :share, ScItem do |item|
          item.shareable &&
            !item.in_progress
        end

        can :manage, DivisionDisplayScItem do |item|
          user.as_divisions.include? Division.find(item.division_id)
        end

        #can edit non-admin/super-admin users
        can [:index, :new, :create, :show], User
        can [:edit, :update], User do |u|
          !u.as_super_admin? && (u.divisions & user.as_divisions).present?
        end
        can [
          :change_email,
          :update_email,
          :change_password,
          :update_password,
          :change_local_referral_area,
          :update_local_referral_area
        ], User

        can [:index, :new, :create, :show, :copy], NewsItem
        can [:edit, :update], NewsItem do |news_item|
          user.as_divisions.include? news_item.owner_division
        end

        can [:show, :edit, :update, :hide_updates], Division do |division|
          user.as_divisions.include? division
        end

        can :manage, FeedbackItem do |feedback_item|
          feedback_item.item.present? && (
            (
              feedback_item.item.instance_of?(Specialist) &&
              (feedback_item.item.divisions & user.as_divisions).present?
            ) || (
              feedback_item.item.instance_of?(Clinic) &&
              (feedback_item.item.divisions & user.as_divisions).present?
            ) || (
              feedback_item.item.instance_of?(ScItem) &&
              ([feedback_item.item.division] & user.as_divisions).present?
            )
          )
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
          Specialist,
          Clinic,
          Hospital,
          Language,
          ScCategory,
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
          :update_password,
          :change_local_referral_area,
          :update_local_referral_area
        ], User

        can [:create, :show], FeedbackItem

        can :index, Notification

        can :manage, Subscription

        can [:create], Note
        can :destroy, Note do |note|
          note.user == user
        end

        can :view_history, Historical

      elsif user.as_user?
        can :show, [Specialization, Procedure] do |entity|
          !entity.fully_in_progress_for_divisions(Division.all)
        end

        can :city, Specialization do |entity|
          !entity.fully_in_progress_for_divisions(Division.all)
        end

        can :show, [Specialist, Clinic] do |entity|
          !entity.in_progress
        end

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
          :update_password,
          :change_local_referral_area,
          :update_local_referral_area
        ], User

        can [:create, :show], FeedbackItem

        can [:update, :photo, :update_photo], Specialist do |specialist|
          specialist.controlling_users.include? user
        end

        can :update, Clinic do |clinic|
          clinic.controlling_users.include? user
        end

      end

      # No one can update items that need review unless they made the review.
      cannot :update, Specialist do |specialist|
        specialist.review_item.present? && specialist.review_item.editor != user
      end

      cannot :update, Clinic do |clinic|
        clinic.review_item.present? && clinic.review_item.editor != user
      end

    end
  end
end
