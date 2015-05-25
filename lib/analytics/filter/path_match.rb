class PathMatch
  def exec(table)
    new_rows = table.rows.select {|row| row[:page_path][filter[:path_regexp]] }

    AnalyticsTable.new(new_rows)
  end
end
