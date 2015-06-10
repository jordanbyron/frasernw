module Analytics
  module Reducer
    def self.for(options)
      case options[:metric]
      when :visitor_accounts
        Analytics::Reducer::VisitorAccounts
      else
        Analytics::Reducer::Null
      end.new(options)
    end
  end
end
