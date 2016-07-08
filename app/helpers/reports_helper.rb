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
      use_divisions =
        if current_user.as_super_admin?
          Division.all
        else
          current_user.as_divisions
        end

      content_tag(:option, "") +
        use_divisions.map do |division|
          report_index_dropdown_option(
            report_type,
            division
          )
        end.join.html_safe
    end
  end
end
