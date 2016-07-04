module ReportsHelper
  def report_index_dropdown_option(report_type, division)
    content_tag(
      :option,
      division.name,
      value: send("#{report_type}_reports_path", division_id: division.id)
    )
  end

  def report_index_dropdown(report_type)
    content_tag(
      :select,
      onChange: "window.location = event.target.value"
    ) do
      "<option value=\"\"></option>".html_safe +
        Division.all.map do |division|
          report_index_dropdown_option(
            report_type,
            division
          )
        end.join.html_safe
    end
  end
end
