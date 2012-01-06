class ClinicsController < ApplicationController
  load_and_authorize_resource

  def index
    @clinics = Clinic.all
  end

  def show
    @clinic = Clinic.find(params[:id])
    render :layout => false if request.headers['X-PJAX']
  end

  def new
    @clinic = Clinic.new
    @clinic.clinic_specializations.build( :specialization_id => Specialization.first.id )
    @clinic.addresses.build
    @clinic.focuses.build
    @clinic.attendances.build
    @clinic_procedures = procedure_specialization_ancestry_options( Specialization.first.procedure_specializations.arrange )
    @clinic_specialists = []
    Specialization.first.specialists.each { |specialist|
      @clinic_specialists << [ specialist.name, specialist.id ]
    }
  end

  def create
    @clinic = Clinic.new(params[:clinic])
    if @clinic.save
      redirect_to clinic_path(@clinic), :notice => "Successfully created clinic."
    else
      render :action => 'new'
    end
  end

  def edit
    @clinic = Clinic.find(params[:id])
    if @clinic.focuses.count == 0
      @clinic.focuses.build
    end
    @clinic_procedures = []
    @clinic.specializations.each { |specialization| 
      @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
      @clinic_procedures += procedure_specialization_ancestry_options( specialization.procedure_specializations.arrange )
    }
    @clinic_specialists = []
    @clinic.specializations.each { |specialization|
      @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
      specialization.specialists.each { |specialist|
        @clinic_specialists << [ specialist.name, specialist.id ]
      }
    }
  end

  def update
    params[:clinic][:procedure_ids] ||= []
    @clinic = Clinic.find(params[:id])
    if @clinic.update_attributes(params[:clinic])
      redirect_to @clinic, :notice  => "Successfully updated clinic."
    else\
      render :action => 'edit'
    end
  end

  def destroy
    @clinic = Clinic.find(params[:id])
    @clinic.destroy
    redirect_to clinics_url, :notice => "Successfully destroyed clinic."
  end
  
  def procedure_specialization_ancestry_options(items, &block)
    return procedure_specialization_ancestry_options(items){ |i| "#{'-' * i.depth} #{i.procedure.name}" } unless block_given?
    
    result = []
    items.map do |item, sub_items|
      result << [yield(item), item.id]
      result += procedure_specialization_ancestry_options(sub_items, &block)
    end
    result
  end
end
