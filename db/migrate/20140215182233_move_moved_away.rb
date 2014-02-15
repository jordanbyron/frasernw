class MoveMovedAway < ActiveRecord::Migration
  def change
    Specialist.all.reject{ |s| s.categorization_mask != 5 }.each do |s|
      puts s.name
      s.categorization_mask = 1
      s.status_mask = 10
      s.save
    end
  end
end
