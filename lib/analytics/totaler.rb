module Analytics
  module Totaler
    def self.for(options)
      Analytics::Totaler::Query.new(options)
    end
  end
end
