# accepts Clinic or Specialist classes and reports on their waittimes
class WaitTimeReporter
  attr_reader :model, :division

  def initialize(model, options = {})
    @model = model
    @division = options[:division]
  end

  def all
    model::WAITTIME_LABELS
  end

  def masks
    model::WAITTIME_LABELS.keys
  end

  def labels
    model::WAITTIME_LABELS.values
  end

  def counts
    masks.map do |mask|
      count(mask)
    end
  end

  def count(mask)
    scope = model.where(waittime_mask: mask)
    scope = model.filter(scope, division: division) if division.present?
    scope.count
  end

  def median
    scope = model.where("waittime_mask IS NOT NULL")
    scope = scope.filter(scope, division: division) if division.present?

    midpoint = (scope.count.to_f / 2).ceil

    scope.sort_by do |specialist|
      specialist.consultation_wait_time_mask
    end[midpoint].try(:waittime)
  end
end
