class UnauthenticatedUser
  include DivisionAdministered

  def authenticated?
    false
  end

  def mask
    nil
  end

  [
    :divisions,
    :as_divisions
  ].each do |mname|
    define_method mname do
      []
    end
  end

  [
    :division_id,
    :adjusted_type_mask,
    :type_mask,
    :id
  ].each do |mname|
    define_method mname do
      -1
    end
  end

  [
    :super_admin?,
    :admin?,
    :admin_or_super?,
    :user?,
    :introspective?
  ].each do |mname|
    define_method mname do
      false
    end

    define_method "as_#{mname}" do
      false
    end
  end
end
