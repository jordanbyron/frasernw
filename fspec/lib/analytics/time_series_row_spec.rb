# this class uses some metaprogramming relying on this constant, but I don't want to load up all of activerecord to test it..
class Metric
  DIMENSIONS = [:division_id]
end

require 'lib/analytics/time_series_row'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/keys'
require 'active_support/hash_with_indifferent_access'
require 'ostruct'
require 'lib/month'

describe Analytics::TimeSeriesRow do
  let(:cells) do
    [
      OpenStruct.new(
        month_stamp: 199101,
        page_views: 4,
        attributes: {
          division_id: 1,
          month_stamp: 199101,
          page_views: 4
        }
      ),
      OpenStruct.new(
        month_stamp: 199102,
        page_views: 5,
        attributes: {
          division_id: 1,
          month_stamp: 199102,
          page_views: 5
        }
      )
    ]
  end

  describe "#initialize" do
    it "should aggregate the cells to a time series row" do
      expect { Analytics::TimeSeriesRow.new(cells, :page_views) }.to_not raise_error
    end
  end

  describe "#dimensions" do
    it "should return its value for each dimension" do
      row = Analytics::TimeSeriesRow.new(cells, :page_views)
      expect(row.division_id).to eq(1)
    end
  end

  describe "#val" do
    it "should return its value for the month given" do
      month = Month.new(1991, 1)
      row = Analytics::TimeSeriesRow.new(cells, :page_views)
      expect(row[month]).to eq(4)
    end
  end
end
