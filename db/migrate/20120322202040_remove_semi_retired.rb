class RemoveSemiRetired < ActiveRecord::Migration
  def change
    
    Specialist.all.each do |s|
      if s.status_mask == 3
        say "#{s.name} was semi-retired, is now didn't answer"
        s.status_mask = 7
        s.save
      end
    end
    
  end
end
