class HideNoDivision < ActiveRecord::Migration
  def up
    specialists_to_hide = (Specialist.all - Specialist.in_divisions(Division.all)).
      to_a.
      reject(&:hidden)

    puts "Hiding specialists: #{specialists_to_hide.map(&:id)}"

    specialists_to_hide.each do |specialist|
      specialist.update_attribute(:hidden, true)
    end

    clinics_to_hide = (Clinic.all - Clinic.in_divisions(Division.all)).
      to_a.
      reject(&:hidden)

    puts  "Hiding clinics: #{clinics_to_hide.map(&:id)}"

    clinics_to_hide.each{ |clinic| clinic.update_attribute(:hidden, true) }
  end

  def down
  end
end
