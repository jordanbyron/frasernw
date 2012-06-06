class UpdateRetiredDate < ActiveRecord::Migration
  def change
    Specialist.all.reject{ |s| s.status_mask != 4 }.each do |s|
      puts s.name
      s.unavailable_from = Date.new(2012, 1, 1)
      s.save
    end
  end
end
