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
    @video = Video.new(video_params)
    if @video.save
      redirect_to @video, notice: "Successfully created video."
    else
      redirect_to new_video_path,
        notice: "Please complete all required fields before submitting."
    end
  end

  def edit
    authorize! :edit, Video
    @video = Video.find(params[:id])
  end

  def update
    authorize! :update, Video
    @video = Video.find(params[:id])
    if @video.update_attributes(video_params)
      redirect_to @video, notice: "Successfully updated video."
    else
      redirect_to @video,
        notice: "Please complete all required fields before submitting."
    end
  end

  def destroy
    authorize! :destroy, Video
    @video = Video.find(params[:id])
    if @video.destroy
      redirect_to videos_path, notice: "Successfully deleted video"
    else
      redirect_to @video, notice: "Something went wrong. Please try again."
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :video_clip)
  end
end
