class SetUpInitialDivision < ActiveRecord::Migration
  def change
    
    #make our first super admin
    user = User.find(10).update_attribute(:role, 'super')
    
    #make our first division
    division = Division.new(:name => "Fraser Northwest")
    division.cities << City.find(3)  #Burnaby
    division.cities << City.find(4)  #Coquitlam
    division.cities << City.find(7)  #New Westminster
    division.cities << City.find(9)  #Port Coquitlam
    division.cities << City.find(10) #Port Moody
    division.save
    
    #make our current specialization owners belong to this division
    SpecializationOwner.all.each do |so|
      so.division = division
      so.save
    end
    
    #make all our current users belong to this division
    User.all.each do |user|
      user.divisions << division
      user.save
    end
  end
end
