class AddRespondedToSurveyToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :responded, :boolean, :default => true
  end
end
