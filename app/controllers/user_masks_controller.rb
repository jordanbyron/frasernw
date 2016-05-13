class UserMasksController < ApplicationController
  skip_authorization_check
  skip_authorize_resource

  def new
    redirect_to root_path unless current_user.admin_or_super?
    @user_mask = current_user.mask || current_user.build_mask(
      role: current_user.role,
      division_ids: current_user.divisions.map(&:id)
    )

    @cancel_text = cancel_text(@user_mask)
  end

  def create
    redirect_to root_path unless current_user.admin_or_super?

    @user_mask = current_user.mask || current_user.build_mask

    params_to_validate = {
      role: params[:user_mask][:role],
      division_ids: params[:user_mask][:division_ids].select(&:present?).map(&:to_i)
    }

    redirection_path =
      if params[:mask_request_origin].present?
        Base64.decode64(params[:mask_request_origin].to_s)
      else
        root_path
      end

    if ValidateUserMask.call(existing_mask: @user_mask, new_params: params_to_validate)
      @user_mask.update_attributes(params_to_validate)

      redirect_to redirection_path,
        notice: "Now viewing Pathways as #{current_user.as_role_label.indefinitize} in the following divisions: #{current_user.as_divisions.to_sentence}."
    else
      flash[:notice] = "Invalid divisions or role."

      @cancel_text = cancel_text(@user_mask)

      render :new
    end
  end

  def update
    redirect_to root_path unless current_user.admin_or_super?
    redirect_to new_user_mask_path unless current_user.mask.present?


    user_mask = current_user.mask
    params_to_validated = params.slice(:role, :division_ids)

    if ValidateUserMask.call(existing_mask: user_mask, params: params_to_validated)
      user_mask.update_attributes(params_to_validated)

      redirect_to request.referrer,
        notice: "Now viewing Pathways as #{current_user.as_role_label.indefinitize} in the following divisions: #{current_user.as_divisions.to_sentence}."
    else
      redirect_to new_user_mask_path,
        notice: "Invalid division or role"
    end
  end

  def destroy
    current_user.mask.try(:destroy)

    redirection_path =
      if params[:mask_request_origin].present?
        Base64.decode64(params[:mask_request_origin].to_s)
      else
        root_path
      end

    redirect_to redirection_path,
      notice: "Now viewing Pathways with your default role and divisions."
  end

  private

  def cancel_text(user_mask)
    if @user_mask.persisted?
      "Return to Default View"
    else
      "Cancel"
    end
  end

end
