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
          (entity.divisions & user.divisions).present?
        end
        
        #can edit non-admin/super-admin users
        can :manage, User do |user|
          user.user?
        end
        
      end
      
      if user.admin_only? || user.user?
        
        #user
         
        #landing page
        can [:index, :faq, :terms_and_conditions], Front
        
        #can show pages
        can :show, [Specialization, Procedure, Specialist, Clinic, Hospital, Language, ScCategory, ScItem]
        
        #can print patient information
        can :print_patient_information, [Specialist, Clinic]
        
        #can change name, email, password
        #can [:change_name, :update_name], User
        can [:change_email, :update_email], User
        can [:change_password, :update_password], User
        
        #can add feedback
        can [:create, :show], FeedbackItem
        
        #can update users they control
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
