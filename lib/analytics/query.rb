module Analytics
  # parses options fed to frame module to construct a query params for the api adapter
  module Query
    def self.for(options)
      case options[:metric]
      when :visitor_accounts
        Analytics::Query::VisitorAccounts
      else
        Analytics::Query::Default
      end.new(options)
    end
  end
end
