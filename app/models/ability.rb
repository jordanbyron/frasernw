class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      
      can :manage, :all
      
    else
      
      can :show, [Specialization, Specialist, Clinic, Hospital]
      can :blank, Specialization #landing page
      
      can :update, Clinic do |clinic|
        false #TODO return true if this is a clinic mapped to a user
      end
      
      can :update, Specialist do |specialist|
        false #TODO return true if this is a specialist mapped to a user
      end
      
    end

    # Cannot update items that need review.
    cannot :update, Specialist do |specialist|
      specialist.versions.last.to_review? == true
    end
    
  end
end
