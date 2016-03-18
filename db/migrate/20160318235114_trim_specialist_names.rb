class TrimSpecialistNames < ActiveRecord::Migration
  def up
    Specialist.all.each do |specialist|
      next if specialist.lastname.nil?

      if specialist.lastname != specialist.lastname.strip
        specialist.update_attribute(:lastname, specialist.lastname.strip)
      end
    end
  end

  def down
  end
end
