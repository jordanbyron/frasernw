module UsersHelper

  def user_edit_checkbox_value_for_division
    if @user.as_divisions.present?
      @user.as_divisions.map(&:id)
    elsif current_user.as_super_admin?
      nil
    elsif current_user.as_divisions.count > 1 # otherwise keep blank if assignment of division is missing and admin has multiple divisions
      nil
    else
      current_user.as_divisions.first.id  # default to division of admin user if admin only has 1 division
    end
  end

  def disable_editing_user_division
    if current_user.as_divisions.count <= 1 && !current_user.as_super_admin?
      true # disable ability to change user's division
    else
      false
    end
  end
end
