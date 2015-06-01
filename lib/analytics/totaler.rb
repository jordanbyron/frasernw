module Analytics
  module Totaler
    def self.for(options)
      case options[:metric]
      when :visitor_accounts
        Analytics::Totaler::Sum
      else
        Analytics::Totaler::Analytics
      end.new(options)
    end
  end
end
