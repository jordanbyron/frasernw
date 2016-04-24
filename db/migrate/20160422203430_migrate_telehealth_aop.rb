class MigrateTelehealthAop < ActiveRecord::Migration
  def up
    Specialist.all.each do |specialist|
      BuildTeleservices.call(provider: specialist)

      procedure_names = specialist.procedures.map(&:name)

      if procedure_names.include?("Telehealth clinical consultation")
        specialist.teleservices.where(key:
    end
  end

  def down
  end
end
