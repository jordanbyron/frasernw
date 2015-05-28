class Metric < ActiveRecord::Base
  DIMENSIONS = [:page_path, :user_type_key, :division_id]

  def self.transform_metric(metric)
    if options[:min_sessions].nil?
      metric
    else
      "#{metric}_min#{options[:min_sessions]}sessions"
    end.to_sym
  end

  def self.aggregate_find(query)
    where(DIMENSIONS.to_nil_hash.merge(query)).first
  end

  def self.aggregate(options)
    # parse the options to a valid 'where clause'
    breakdown_by = options.delete(:breakdown)
    path_regexp = options.delete(:path_regexp)
    metric = options.delete(:metric)

    # will be set to null to aggregate over those dimensions
    total_over = DIMENSIONS
    total_over = total_over - [ breakdown_by ] if breakdown_by.present?
    total_over = total_over - [ page_path ] if page_path.present?
    total_over = total_over - options.keys

    records = where(options)
    records = where(total_over.to_nil_hash)
    records = where("? != ?", breakdown_by.to_s, nil) if breakdown_by.present?
    records = where("page_path ~* ?", path_regexp) if path_regexp.present?

    Analytics::CellAggregator.time_series(records, metric)
  end


end
