require 'lib/hash_table'
require 'lib/analytics/reducer/user'

describe Analytics::Reducer::User do
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
      reducer = Analytics::Reducer::User.new(
        sample_table,
        dimensions: [ :user_type_key, :division_id ]
      )

      reducer.exec.rows == [
        {:user_type_key=>"-1", :division_id=>"-1",:users=>2},
        {:user_type_key=>"-1", :division_id=>"2", :users=>1},
        {:user_type_key=>"-1", :division_id=>"3", :users=>2},
        {:user_type_key=>"0", :division_id=>"1", :users=>6}
      ]
    end
  end
end
