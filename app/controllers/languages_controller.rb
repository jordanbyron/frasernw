class LanguagesController < ApplicationController
  skip_before_filter :require_authentication, only: :refresh_cache
  load_and_authorize_resource except: :refresh_cache
  before_filter :check_token, only: :refresh_cache
  skip_authorization_check only: :refresh_cache

  def index
    @languages = Language.all
  end

  def show
    @language = Language.find(params[:id])
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(params[:language])
    if @language.save
      redirect_to @language, notice: "Successfully created language."
      else
      render action: 'new'
    end
  end

  def edit
    @language = Language.find(params[:id])
  end

  def update
    @language = Language.find(params[:id])
    ExpireFragment.call language_path(@language)
    if @language.update_attributes(params[:language])
      redirect_to @language, notice: "Successfully updated language."
      else
      render action: 'edit'
    end
  end

  def destroy
    @language = Language.find(params[:id])
    ExpireFragment.call language_path(@language)
    @language.destroy
    redirect_to languages_url, notice: "Successfully deleted language."
  end

  def check_token
    token_required( Language, params[:token], params[:id] )
  end

  def refresh_cache
    @language = Language.find(params[:id])
    render :show
  end
end
