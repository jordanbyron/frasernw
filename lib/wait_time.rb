class WaitTime
  def self.all
    Specialist::WAITTIME_HASH
  end

  def self.masks
    Specialist::WAITTIME_HASH.keys
  end

  def self.labels
    Specialist::WAITTIME_HASH.values
  end

  def self.counts(options = {})
    masks.map do |mask|
      count(mask, division: options[:division])
    end
  end

  def self.count(mask, options = {})
    division = options[:division]

    scope = Specialist.where(waittime_mask: mask)
    scope = Specialist.filter(scope, division: division) if division.present?
    scope.count
  end

  def self.median(options = {})
    division = options[:division]

    scope = Specialist.where("waittime_mask IS NOT NULL")
    scope = scope.filter(scope, division: division) if division.present?

    midpoint = (scope.count.to_f / 2).ceil

    scope.sort_by do |specialist|
      specialist.waittime_mask
    end[midpoint].try(:waittime)
  end
end
