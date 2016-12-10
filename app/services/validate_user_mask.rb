class ValidateUserMask < ServiceObject
  attribute :existing_mask, User
  attribute :new_params, Hash

  def call
    role_valid? && divisions_valid?
  end

  def new_attrs
    @new_attrs ||= {
      role: existing_mask.role,
      division_ids: existing_mask.divisions.map(&:id)
    }.merge(new_params.slice(:division_ids, :role))
  end

  def role_valid?
    (
      new_attrs[:role].present? &&
        existing_mask.user.can_assign_mask_roles.include?(new_attrs[:role])
    )
  end

  def divisions_valid?
    new_attrs[:division_ids].any? &&
      new_attrs[:division_ids].all? do |id|
        existing_mask.user.can_assign_divisions.map(&:id).include?(id)
      end
  end
end
