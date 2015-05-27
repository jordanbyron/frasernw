require 'lib/hash_table'
require 'lib/analytics/analytics_table'
require 'lib/analytics/filter/base'
require 'lib/analytics/filter/path_match'


describe Analytics::Filter::PathMatch do
  let(:sample_data) do
    [
      { :user_type_key=>"-1", :page_path=>"/", :users => 1 },
      { :user_type_key=>"-1", :page_path=>"/content_items/429", :users => 2 },
      { :user_type_key=>"-1", :page_path=>"/login", :users => 4 }
    ]
  end
  let(:sample_table) do
    Analytics::AnalyticsTable.new(sample_data)
  end

  describe "exec" do
    it "should return the data collapsed by user id" do
      filter = Analytics::Filter::PathMatch.new(
        path_regexp: /\/content_items\//
      )

      expect(filter.exec(sample_table).rows).to contain_exactly(
        { :user_type_key=>"-1", :page_path=>"/content_items/429", :users => 2 }
      )
    end
  end
end
