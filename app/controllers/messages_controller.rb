class MessagesController < UserSessionsController

  def new
    render :new, layout: "user_sessions"
  end

  def create
    @message = Message.new(params[:message])

    if @message.valid?
      MessagesMailer.new_message(@message, current_user).deliver

      respond_to do |format|
        format.json{ render json: {}, status: 200 }
        format.html{ render :create, layout: "user_sessions" }
      end
    else
      respond_to do |format|
        format.json{ render json: {}, status: 400 }
        format.html do
          flash.now.alert = "Please complete all the fields."

          render :new, layout: "user_sessions"
        end
      end
    end
  end
end
