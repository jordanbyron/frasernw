class LanguagesController < ApplicationController
    load_and_authorize_resource
    
    def index
      @languages = Language.all
      render :layout => 'ajax' if request.headers['X-PJAX']
    end
    
    def show
      @language = Language.find(params[:id])
      render :layout => 'ajax' if request.headers['X-PJAX']
    end
    
    def new
        @language = Language.new
    end
    
    def create
        @language = Language.new(params[:language])
        if @language.save
            redirect_to @language, :notice => "Successfully created language."
            else
            render :action => 'new'
        end
    end
    
    def edit
        @language = Language.find(params[:id])
    end
    
    def update
        @language = Language.find(params[:id])
        if @language.update_attributes(params[:language])
            redirect_to @language, :notice  => "Successfully updated language."
            else
            render :action => 'edit'
        end
    end
    
    def destroy
        @language = Language.find(params[:id])
        @language.destroy
        redirect_to languages_url, :notice => "Successfully deleted language."
    end
end
