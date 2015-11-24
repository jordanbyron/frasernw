namespace :pathways do
  task remove_deceased_specialist_records: :environment do
    RemoveDeceasedSpecialistRecords.call
  end
end
