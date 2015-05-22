module Analytics
  module CsvPresenter
    def self.exec(options)
      Base.exec(options)
    end

    def self.by_path(options)
      Path.exec(options)
    end
  end
end
