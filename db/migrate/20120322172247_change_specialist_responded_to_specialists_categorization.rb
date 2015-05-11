class ChangeSpecialistRespondedToSpecialistsCategorization < ActiveRecord::Migration
  def change
    add_column :specialists, :categorization_mask, :integer, :default => 1

    Specialist.all.each do |s|
      if s.responded
        s.categorization_mask = 1
      else
        s.categorization_mask = 2
      end
      s.save
    end

    remove_column :specialists, :responded
  end
end
