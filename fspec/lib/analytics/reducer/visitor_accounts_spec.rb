require 'lib/hash_table'
require 'lib/analytics/reducer/visitor_accounts'
require 'active_support/core_ext/array/grouping'

describe Analytics::Reducer::VisitorAccounts do
  let(:sample_data) do
    [
      {:user_type_key=>"-1", :division_id=>"-1", :user_id=>"-1", :sessions=>"8"},
      {:user_type_key=>"-1", :division_id=>"1", :user_id=>"-1", :sessions=>"306"},
      {:user_type_key=>"-1", :division_id=>"2", :user_id=>"-1", :sessions=>"22"},
      {:user_type_key=>"-1", :division_id=>"3", :user_id=>"-1", :sessions=>"2"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"10", :sessions=>"22"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"11", :sessions=>"73"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"12", :sessions=>"6"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"3", :sessions=>"35"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"31", :sessions=>"2"},
      {:user_type_key=>"0", :division_id=>"1", :user_id=>"4", :sessions=>"2"}
    ]
  end
  let(:sample_table) do
    HashTable.new(sample_data)
  end

  describe "exec" do
    it "should return the data collapsed by user id" do
      reducer = Analytics::Reducer::VisitorAccounts.new(
        dimensions: [ :user_type_key, :division_id ]
      )

      expect(reducer.exec(sample_table).rows).to contain_exactly(
        {:user_type_key=>"-1", :division_id=>"-1",:visitor_accounts=>1},
        {:user_type_key=>"-1", :division_id=>"1", :visitor_accounts=>1},
        {:user_type_key=>"-1", :division_id=>"2", :visitor_accounts=>1},
        {:user_type_key=>"-1", :division_id=>"3", :visitor_accounts=>1},
        {:user_type_key=>"0", :division_id=>"1", :visitor_accounts=>6}
      )
    end
  end
end
