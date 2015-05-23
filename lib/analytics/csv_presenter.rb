# gets the appropriate abstract table (array of hashes) and converts it to an array of arrays, a format the CSV service can handle
module Analytics
  module CsvPresenter
    DEFAULT_DIMENSIONS = [ :division_id, :user_type_key ]
    PRESENTER_CLASSES = ArrayDictionary.new(
      [:division_id, :user_type_key] => Base,
      [:specialty, :user_type_key] => Specialty,
      [:resource_category, :user_type_key] => Resource
    )

    def self.exec(options)
      options[:dimensions] ||= DEFAULT_DIMENSIONS

      klass_for(options[:dimensions).new(options)
    end

    def klass_for(dimensions)
      PRESNTER_CLASSES.find(dimensions)
    end
  end
end
