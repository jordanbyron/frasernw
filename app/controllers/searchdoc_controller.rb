class SearchdocController < ApplicationController
skip_authorization_check
def navigation
  @specializations = Specialization.all
  @specialists = Specialist.all
  @clinics = Clinic.all
end
def tree
#RPW TODO optimize by this?
    #@specializations = Specialization.find(:all, :include => [ :specialists, :clinics, { :procedure_specializations => :procedure } ] )
    @specializations = Specialization.all
  respond_to do |format|
    format.js
    # format.xml { render :xml => @specializations }
    # format.xml { render :xml => @specializations }
  end  
end

def index
  @specializations = Specialization.all
  respond_to do |format|
    format.js
  end
end

end
