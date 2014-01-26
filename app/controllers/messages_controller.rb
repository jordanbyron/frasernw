class MessagesController < ApplicationController
  authorize_resource
  
  def new
    @message = Message.new
    render layout: 'contact'
  end
  
  def create
    @message = Message.new(params[:message])
    
    if @message.valid?
      MessagesMailer.new_message(@message).deliver
      redirect_to(root_path, :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
      render :new, layout: 'contact'
    end
  end
  
end