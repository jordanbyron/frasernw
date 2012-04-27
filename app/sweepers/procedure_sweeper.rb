class ProcedureSweeper < ActionController::Caching::Sweeper
  observe Procedure
  
  def after_create(procedure)
    expire_cache_for(procedure)
  end
  
  def after_update(procedure)
    expire_cache_for(procedure)
  end
  
  def after_destroy(procedure)
    expire_cache_for(procedure)
  end
  
  def expire_cache_for(procedure)
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire procedures page
    expire_fragment :controller => 'procedures', :action => 'show'
    
    #expire all specialization pages that the procedure is in
    procedure.specializations_including_in_progress.each do |s|
      expire_fragment :controller => 'specializations', :action => 'show', :id => s.id
    end
    
    #expire all specialists pages that perform this procedure
    procedure.specialists_including_in_progress.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
  end
end