module HasRole
  def user?
    role == 'user'
  end

  def admin?
    role == 'admin'
  end

  def admin_or_super?
    admin? || super_admin?
  end

  def super_admin?
    role == 'super'
  end

  def introspective?
    role == 'introspective'
  end

  def role_label
    User::ROLE_LABELS[role]
  end

  def administering
    if super_admin?
      Division.all
    elsif admin?
      divisions
    else
      []
    end
  end
end
