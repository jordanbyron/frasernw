module TestScCategories
  def self.exec
    division_ids = Division.pluck(:id)

    10.times do
      division1 = Division.find(division_ids.sample)
      division2 = Division.find(division_ids.sample)
      divisions = [division1, division2]

      res1 = ScCategory.old_global_resources_dropdown(divisions)
      res2 = ScCategory.global_resources_dropdown(divisions)

      if res1.map(&:id).sort != res2.map(&:id).sort
        raise
      end
    end
  end
end
