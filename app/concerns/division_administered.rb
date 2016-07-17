module DivisionAdministered
  def owner_divisions
    if divisions.any?
      divisions
    else
      [ Division.provincial ]
    end
  end

  def owners
    owner_divisions.map{|division| division.owners_for(self) }.flatten.uniq
  end
end
