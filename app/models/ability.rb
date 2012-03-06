class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      
      can :manage, :all
      
    else
      
      can :show, [Specialization, Procedure, Specialist, Clinic, Hospital, Language]
      can :blank, Specialization #landing page
      
      can :update, Specialist do |specialist|
        specialist.controlling_users.include? user
      end
      
      can :update, Clinic do |clinic|
        clinic.controlling_users.include? user
      end
      
    end

    # Cannot update items that need review.
    cannot :update, Specialist do |specialist|
      specialist.review_item.present?
    end
    
  end
end
