module Analytics
  class WebPresenter
    def self.time_series(metric, options)
      if options[:path]
        table = Analytics::TimeSeries.by_path(metric, options.slice(:dates))
      else
        table = Analtyics::TimeSeries.exec(metric, options.slice(:dates))
      end

      table.search(other_options).present_for_web
    end
  end
end
