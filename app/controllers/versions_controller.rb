class VersionsController < ApplicationController
  load_and_authorize_resource

  def index
    klass = params[:model].singularize.camelize.constantize
    @item = klass.find params[:id]
    @versions = @item.versions
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
  
  def show
    @version = Version.find(params[:id])
    @klass = @version.reify.class.to_s.downcase
    eval("@#{@klass} = @version.reify" )
    @is_version = true
    if @klass == "specialist"
      render 'specialists/show', :layout => 'ajax' if request.headers['X-PJAX']
    elsif @klass == "clinic"
      render 'clinics/show', :layout => 'ajax' if request.headers['X-PJAX']
    else
      redirect_to root_url and return;
    end
  end

  def show_all
    @versions = Version.order('id desc').paginate(:page => params[:page], :per_page => 30)
    render :layout => 'ajax' if request.headers['X-PJAX']
  end

  def revert
    @version = Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      if @version.item.specialization
        klass = @version.item.specialization.class.to_s.downcase.pluralize.to_sym
        @version.item.destroy
        redirect_to klass and return
      else
        redirect_to '/' and return
      end
    end
    link_name = params[:redo] == "true" ? "undo" : "redo"
    link = view_context.link_to(link_name, revert_version_path(@version.next, :redo => !params[:redo]), :method => :post)
    redirect_to :back, :notice => "Undid #{@version.event}. #{link}"
  end

end

