class Table
  attr_reader :rows

  # takes an array of hashes
  def initialize(rows)
    @rows = rows
  end

  def columns
    rows.inject([]) do |memo, row|
      memo | rows.keys
    end
  end

  def collapse_subsets!(uniq_function, base_accumulator, accumulator_function)
    subsets = rows.subsets uniq_function

    # Construct the collapsed rows to put back into the table
    collapsed_rows = subsets.map do |set|
      accumulator = base_accumulator.dup

      set.inject(accumulator) do |accumulator, row|
        accumulator_function.call(accumulator, row)
      end
    end

    puts collapsed_rows

    @rows = collapsed_rows
  end

  def collapse_subset!(test, base_accumulator, accumulator_function)
    # Get the rows we want to collapse
    subset = rows.select {|row| test.call(row) }

    # Delete them from the table
    rows.reject! {|row| test.call(row) }

    # Build a collapsed row to put back into the table
    accumulator_row = subset.inject(base_accumulator) do |memo, row|
      accumulator_function.call(memo, row)
    end

    @rows = rows << accumulator_row
  end

  def transform_column!(column_key)
    rows.map do |row|
      row[column_key] = yield(row)
    end
  end
end
