class SortSpecialistOffices < ActiveRecord::Migration
  def change
    Specialist.all.each do |specialist|
      specialist.specialist_offices.each do |so|
        specialist.specialist_offices.destroy(so) if so.empty?
      end
    end   
  end
end
