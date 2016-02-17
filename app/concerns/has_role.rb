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

  def role_label
    User::ROLE_LABELS[role]
  end
end
