class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      
      #not logged in
      
      #can't do anything
      
    elsif user.admin?
      
      #admin
      
      #can do anything
      can :manage, :all
      
    else
      
      #user
      
      #can show pages
      can :show, [Specialization, Procedure, Specialist, Clinic, Hospital, Language]
      can :blank, Specialization #landing page
      
      #can update users they control
      can :update, Specialist do |specialist|
        specialist.controlling_users.include? user
      end
      
      #can update clinics they control
      can :update, Clinic do |clinic|
        clinic.controlling_users.include? user
      end
      
    end

    # No one can update items that need review.
    cannot :update, Specialist do |specialist|
      specialist.review_item.present?
    end
    
  end
end
