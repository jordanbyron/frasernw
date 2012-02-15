class AddInProgressToSpecializations < ActiveRecord::Migration
  def change
    add_column :specializations, :in_progress, :boolean, :default => false
    
    Specialization.all.each do |s|
      s.in_progress = false
      s.save
    end
  end
end
