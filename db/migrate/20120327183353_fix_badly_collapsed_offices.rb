class FixBadlyCollapsedOffices < ActiveRecord::Migration
  def cleanup_address(address)
    return address.sub('avenue', 'ave').sub('street', 'st').sub('.',' ').sub('-',' ').delete(' ')
  end

  def change

    SpecialistAddress.all.each do |sa|

      next if sa.address.blank?
      next if sa.specialist.blank?
      next if sa.address.empty_old?

      s = sa.specialist
      a = sa.address

      #we didn't have phone info
      next if (a.phone1.blank? && a.fax.blank?)

      found = false

      s.specialist_offices.each do |so|

        if ((so.phone == a.phone1) && (so.fax == a.fax))
          found = true
          break
        end

        next if so.phone.present?
        next if so.fax.present?
        next if so.office.blank?
        next if so.office.location.blank?

        new_a = so.office.location.resolved_address
        next if new_a.blank?

        next if a.suite != new_a.suite
        next if a.city != new_a.city
        next if cleanup_address(a.address1.strip.downcase) != cleanup_address(new_a.address1.strip.downcase)

        found = true
        say "#{s.name} at office #{new_a.short_address} now has phone #{a.phone1} and fax #{a.fax}"
        so.phone = a.phone1
        so.fax = a.fax
        so.save
        break

      end

      next if found

      say "ERROR!!! #{s.name} had old phone #{a.phone1} and fax #{a.fax} at address #{a.short_address}, but doesn't have it now and didn't match any current addresses"

    end
  end

end
