module UsersHelper

  def user_edit_checkbox_value_for_division
    if @user.divisions.present?
      @user.divisions.map(&:id)
    elsif current_user_is_super_admin?
      nil
    elsif current_user_has_multiple_user_divisions? # otherwise keep blank if assignment of division is missing and admin has multiple divisions
      nil
    else
      current_user_divisions.first.id  # default to division of admin user if admin only has 1 division
    end
  end

  def disable_editing_user_division
    if !current_user_has_multiple_user_divisions? && !current_user_is_super_admin?
      true # disable ability to change user's division
    else
      false
    end
  end
end
