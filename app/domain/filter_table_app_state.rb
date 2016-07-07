class FilterTableAppState < ServiceObject
  def call
    {
      respondsWithinOptions: Denormalized.fetch(:respondsWithinOptions),
      respondsWithinSummaryLabels: Denormalized.fetch(:respondsWithinSummaryLabels),
      dayKeys: Schedule::DAY_HASH,
      careProviders: Denormalized.fetch(:healthcare_providers),
      tooltips: {
        specialists: Specialist::STATUS_TOOLTIP_HASH.inject({}) do |memo, (k, v)|
          memo.merge(Specialist::STATUS_CLASS_HASH[k] => v)
        end,
        clinics: Clinic::STATUS_HASH.merge({
          0 => Clinic::UNKNOWN_STATUS,
          3 => Clinic::UNKNOWN_STATUS
        })
      },
      waittimeHash: Specialist::WAITTIME_LABELS,
      teleserviceFeeTypes: Teleservice::SERVICE_TYPES.map do |key, value|
        [ key, value.downcase ]
      end.to_h
    }
  end
end
