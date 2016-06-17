module UsersHelper

  def user_edit_checkbox_value_for_division
    if @user.divisions.present?
      @user.divisions.map(&:id)
    elsif current_user.as_super_admin?
      nil
    elsif current_user.as_divisions.count > 1
      nil
    else
      current_user.as_divisions.first.id
    end
  end

  def disable_editing_user_division
    if current_user.as_divisions.count <= 1 && !current_user.as_super_admin?
      true
    else
      false
    end
  end
end
