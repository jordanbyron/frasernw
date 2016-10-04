class RecacheLatestUpdatesInDivisions < ServiceObject
  attribute :division_groups

  def call
    LatestUpdates.recache_for_groups(division_groups)
  end
end
