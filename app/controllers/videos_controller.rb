class VideosController < ApplicationController
  def index
    authorize! :index, Video
    @videos = Video.ordered
  end

  def show
    authorize! :show, Video
    response.headers.delete "X-Frame-Options"
    @video = Video.find(params[:id])
  end

  def new
    authorize! :new, Video
    @video = Video.new
  end

  def create
    authorize! :create, Video
    @video = Video.new(params[:video])
    if @video.save
      redirect_to @video, notice: "Successfully created video"
    else
      redirect_to new_video_path,
        notice: "Please complete all required fields before submitting"
    end
  end

  def edit
    authorize! :edit, Video
    @video = Video.find(params[:id])
  end

  def update
    authorize! :update, Video
    @video = Video.find(params[:id])
    @video.update_attributes(params[:video])
    redirect_to @video, notice: "Successfully updated video"
  end

  def destroy
    authorize! :destroy, Video
    @video = Video.find(params[:id])
    @video.video_clip = nil
    @video.save
    @video.destroy
    redirect_to videos_path, notice: "Successfully deleted video"
  end
end
