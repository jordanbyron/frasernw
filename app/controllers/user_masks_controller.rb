class UserMasksController < ApplicationController
  skip_authorization_check
  skip_authorize_resource

  def new
    redirect_to root_path unless current_user.admin_or_super?
    @user_mask = current_user.mask || current_user.build_mask(
      role: current_user.role,
      division_ids: current_user.divisions.map(&:id)
    )

    @cancel_text = begin
      if @user_mask.persisted?
        "View as Default Role and Divisions"
      else
        "Cancel"
      end
    end
  end

  def create
    redirect_to root_path unless current_user.admin_or_super?

    @user_mask = current_user.mask || current_user.build_mask
    @user_mask.assign_attributes(
      division_ids: params[:user_mask][:division_ids],
      role: params[:user_mask][:role]
    )

    division_assignments_permitted = @user_mask.division_ids.all? do |id|
      current_user.can_assign_divisions.map(&:id).include?(id)
    end

    if !current_user.can_assign_roles.include?(@user_mask.role)
      flash[:notice] = "Invalid role."
      render :new
    elsif !division_assignments_permitted || @user_mask.division_ids.none?
      flash[:notice] = "Invalid divisions."
      render :new
    else
      @user_mask.save

      redirect_to root_path,
        notice: "Now viewing Pathways as #{current_user.as_role_label.indefinitize} in the following divisions: #{current_user.as_divisions.to_sentence}."
    end
  end

  def destroy
    current_user.mask.try(:destroy)

    redirect_to root_path,
      notice: "Now viewing Pathways with your default role and divisions."
  end
end
