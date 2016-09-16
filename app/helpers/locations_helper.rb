module LocationsHelper

  def accessible_cities
    if current_user.as_super_admin?
      City.all
    else
      City.in_divisions(current_user.as_divisions)
    end.map{ |clinic| ["#{clinic.name}, #{clinic.province.symbol}", clinic.id] }
  end

  def accessible_clinics
    if current_user.as_super_admin?
      Clinic.includes_location_data.
        map{ |clinic| clinic.locations }.
        flatten.
        reject{ |location| location.empty? }
    else
      Clinic.includes_location_data.
        in_divisions(current_user.as_divisions).
        map{ |clinic| clinic.locations }.
          flatten.
          reject do |location|
            location.empty? ||
              ![location.city.divisions].include?(current_user.as_divisions)
          end
    end.map do |location|
      [
        "#{location.locatable.clinic.name} #{location.short_address}",
        location.id
      ]
    end
  end

  def accessible_hospitals
    if current_user.as_super_admin?
      Hospital.all
    else
      Hospital.in_divisions(current_user.as_divisions)
    end.reject{ |hospital| hospital.location.blank? }.
      map do |hospital|
        ["#{hospital.name}, #{hospital.location.short_address}", hospital.id]
      end
  end

end
