require 'spec_helper'

describe Table do

  sample_data = [
    row_1: { column_1: 1, column_2: 2, column_3: 3 },
    row_2: { column_1: 1, column_2: 2, column_3: 3 },
    row_5: { column_1: 10, column_2: 11, column_3: 12 }
  ]


  let(:table) { Table.new(sample_data) }

  describe "#collapse_duplicate_rows!" do
    it "collapses duplicates using the test given" do
      table.collapse_duplicate_rows!(
        Proc.new {|row| row[:column_1]},
        {
          column_1: 0,
          column_2: 0,
          column_3: 0
        },
        Proc.new do |accumulator, row|
          accumulator[:]
        end
      )


    end

  end

end
