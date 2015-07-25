module TestAllInDivisions
  def self.exec
    division_ids = Division.pluck(:id)

    10.times do
      division1 = Division.find(division_ids.sample)
      division2 = Division.find(division_ids.sample)
      divisions = [division1, division2]

      count1 = ScItem.all_in_divisions(divisions).count
      count2 = ScItem.new_all_in_divisions(divisions).count

      raise if count1 != count2
    end
  end
end
