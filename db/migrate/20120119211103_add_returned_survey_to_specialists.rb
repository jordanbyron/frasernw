class AddReturnedSurveyToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :responded, :boolean, :default => true
  end
end
