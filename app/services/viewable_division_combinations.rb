class ViewableDivisionCombinations < ServiceObject
  def call
    (User.all_user_division_groups_cached + Division.ids.map{ |id| [ id ] }).
      uniq
  end
end
