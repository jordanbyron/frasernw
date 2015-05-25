module Analytics
  # gets the appropriate abstract table (array of hashes) and converts it to an array of arrays, a format the CSV service can handle
  module CsvPresenter
    DEFAULT_DIMENSIONS = [ :user_type_key, :division_id ]
    PRESENTER_CLASSES =  {
      user_type_key: {
        division_id: Default
      },
      specialty: {
        user_type_key: Specialty
      },
      resource: {
        user_type_key: Resource
      }
    }

    def self.exec(options)
      options[:dimensions] ||= DEFAULT_DIMENSIONS

      klass_for(options[:dimensions).new(options)
    end

    def klass_for(dimensions)
      PRESENTER_CLASSES[dimensions[0]][dimensions[1]]
    end
  end
end
