class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      
      #not logged in
      
      can [:validate, :signup, :setup], User
      
    elsif user.admin?
      
      #admin
      
      #can do anything
      can :manage, :all
      
    else
      
      #user
       
      #landing page
      can :index, Front
      
      #can show pages
      can :show, [Specialization, Procedure, Specialist, Clinic, Hospital, Language]
      
      #can print patient information
      can :print_patient_information, [Specialist, Clinic]
      
      #can change password
      can [:change_password, :update_password], User
      
      #can add feedback
      can [:create, :show], FeedbackItem
      
      #can update users they control
      can :update, Specialist do |specialist|
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
