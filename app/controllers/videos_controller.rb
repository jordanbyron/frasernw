class VideosController < ApplicationController
  def index
    authorize! :index, Video
    @videos = Video.ordered
  end

  def show
    authorize! :show, Video
    response.headers.delete "X-Frame-Options"
    @video = Video.find(params[:id])
    expiring_s3_direct_get
  end

  def new
    authorize! :new, Video
    set_s3_direct_post
    @video = Video.new
  end

  def create
    authorize! :create, Video
    set_s3_direct_post
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
    set_s3_direct_post
    @video = Video.find(params[:id])
  end

  def update
    authorize! :update, Video
    set_s3_direct_post
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
    params.require(:video).permit(:title, :video_url)
  end

  def set_s3_direct_post
    @s3_direct_post =
      Pathways::S3.bucket(:videos).presigned_post(
        key: "video_clips/#{SecureRandom.uuid}/${filename}",
        success_action_status: "201",
        acl: "public-read"
      )
    @encoded_url = URI.encode(@s3_direct_post.url.to_s)
  end

  def expiring_s3_direct_get
    # video_path hackiness compensates for aws-sdk buginess
    video_path = URI(@video.video_url).path
    video_path[0] = ""
    presigner = AWS::S3::PresignV4.new(
      Pathways::S3.bucket(:videos).objects[video_path]
    )
    @expiring_s3_url = presigner.presign(
      :read,
      expires: 30.minutes.from_now.to_i,
      secure: true,
      force_path_style: true,
      acl: "public-read"
    )
  end
end
