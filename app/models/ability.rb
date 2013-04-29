class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      
      #not logged in
      
      can [:validate, :signup, :setup], User
      
    else
      
      if user.super_admin?
      
        #super admin
        
        #can do anything
        can :manage, :all
        
      elsif user.admin_only?
        
        #admin
        
        #can edit specialists, clinics, hospitals, and offices in their division
        can :manage, [Specialist, Clinic, Hospital, Office] do |entity|
          entity.divisions.blank? || (entity.divisions & user.divisions).present?
        end
        can :create, [Specialist, Clinic, Hospital, Office]
        
        #so that an admin can list offices by city for those in their division
        can :read, City do |city|
          (city.divisions & user.divisions).present?
        end
        
        #admin can not list all cities, though
        cannot :index, City
        
        can :manage, ScItem do |item|
          user.divisions.include? item.division
        end
        can :create, ScItem
        
        #can edit non-admin/super-admin users
        can :manage, User do |user|
          user.user?
        end
        
        #can manage their own news items
        can :manage, NewsItem do |news_item|
          (news_item.division & user.divisions).present?
        end
        
        #can manage their own feedback items
        can :manage, FeedbackItem do |feedback_item|
          feedback_item.item.present? &&
            ((feedback_item.item.instance_of?(Specialist) && (feedback_item.item.divisions & user.divisions).present?) ||
             (feedback_item.item.instance_of?(Clinic) && (feedback_item.item.divisions & user.divisions).present?) ||
             (feedback_item.item.instance_of?(ScItem) && ([feedback_item.item.division] & user.divisions).present?))
        end
        
        #can manage their own review items
        can :manage, ReviewItem do |review_item|
          review_item.item.present? &&
            ((review_item.item.instance_of?(Specialist) && (review_item.item.divisions & user.divisions).present?) ||
             (review_item.item.instance_of?(Clinic) && (review_item.item.divisions & user.divisions).present?))
        end
        
        #landing page
        can [:index, :faq, :terms_and_conditions], Front
        
        #can show pages, regardless of 'in progress'
        can :show, [Specialization, Procedure, Specialist, Clinic, Hospital, Language, ScCategory, ScItem]
        
        #can print patient information
        can :print_patient_information, [Specialist, Clinic]
        
        #can show referral forms
        can :index, ReferralForm
        
        #can change name, email, password
        #can [:change_name, :update_name], User
        can [:change_email, :update_email], User
        can [:change_password, :update_password], User
        
        #can add feedback
        can [:create, :show], FeedbackItem
        
      elsif user.user?
        
        #user
         
        #landing page
        can [:index, :faq, :terms_and_conditions], Front
        
        #can show pages that aren't in progress
        can :show, [Specialization, Procedure] do |entity|
          !entity.fully_in_progress_for_divisions(Division.all)
        end
        can :show, [Specialist, Clinic] do |entity|
          !entity.in_progress_for_divisions(entity.divisions)
        end
        can :show, ScItem do |item|
          item.available_to_divisions(user.divisions)
        end
        can :show, [Hospital, Language, ScCategory]

        #can print patient information
        can :print_patient_information, [Specialist, Clinic]
        
        #can show referral forms
        can :index, ReferralForm
        
        #can change name, email, password
        #can [:change_name, :update_name], User
        can [:change_email, :update_email], User
        can [:change_password, :update_password], User
        
        #can add feedback
        can [:create, :show], FeedbackItem
        
        #can update specialists they control
        can [:update, :photo, :update_photo], Specialist do |specialist|
          specialist.controlling_users.include? user
        end
        
        #can update clinics they control
        can :update, Clinic do |clinic|
          clinic.controlling_users.include? user
        end
        
      end
      
      # No one can update items that need review unless they are the ones who made the review.
      cannot :update, Specialist do |specialist|
        specialist.review_item.present? && specialist.review_item.whodunnit != user.id.to_s
      end
      
      cannot :update, Clinic do |clinic|
        clinic.review_item.present? && clinic.review_item.whodunnit != user.id.to_s
      end
      
    end
  end
end
