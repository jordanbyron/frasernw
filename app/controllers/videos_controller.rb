class VideosController < ApplicationController
  def index
    authorize! :index, Video
    @videos = Video.ordered
  end

  def new
    authorize! :new, Video
    @video = Video.new
  end

  def create
    authorize! :create, Video
    @video = Video.create(params[:video])
    redirect_to videos_path, notice: "Successfully created video"
  end

  def edit
    authorize! :edit, Video
    @video = Video.find(params[:id])
  end

  def update
    authorize! :update, Video
    @video = Video.find(params[:id])
    @video.update_attributes(params[:video])
    redirect_to videos_path, notice: "Successfully updated video"
  end

  def destroy
    authorize! :destroy, Video
    Video.find(params[:id]).destroy
    redirect_to videos_path, notice: "Successfully deleted video"
  end
end
