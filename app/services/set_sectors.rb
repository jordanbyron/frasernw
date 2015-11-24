# munges clinic location and specialist office sector params

SetSectors = Proc.new do |attrs|
  next unless attrs.is_a?(Hash)
  next unless ["0", "1"].include?(attrs["sector_info_available"])

  if attrs["sector_info_available"] == "0"
  # 'nil' means 'unknown' on a boolean field
    Sectorable::SECTORS.each do |sector|
      attrs[sector.to_s] = nil
    end
  end

  # cleanup
  attrs.delete("sector_info_available")
end
