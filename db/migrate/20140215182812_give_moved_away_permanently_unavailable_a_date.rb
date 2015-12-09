class GiveMovedAwayPermanentlyUnavailableADate < ActiveRecord::Migration
  def change
    Specialist.all.reject{ |s| !(s.moved_away? || s.permanently_unavailable?) }.each do |s|
      puts s.name
      s.unavailable_from = Date.current - 1.year
      s.save
    end
  end
end
