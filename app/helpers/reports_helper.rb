module ReportsHelper
  def report_row(report_type, divisional: false, manual_label: nil)
    if can?(:view_report, report_type)
      content_tag :tr do
        report_index_label(report_type, manual_label) +
        report_index_scope_options(report_type, divisional)
      end
    else
      ""
    end
  end

  def report_index_label(report_type, manual_label)
    label =
      if manual_label.nil?
        report_type.to_s.split("_").map(&:capitalize).join(" ")
      else
        manual_label
      end

    content_tag :td do
      link_to(label, send("#{report_type}_reports_path"))
    end
  end

  def report_index_scope_options(report_type, divisional)
    content_tag :td do
      contents = link_to(
        "System-wide",
        send("#{report_type}_reports_path")
      )

      if divisional
        contents = contents +
          content_tag(
            :span,
            " or ",
            style: "margin-left: 10px; margin-right: 10px;"
          ) +
          report_index_dropdown(report_type)
      end

      contents
    end
  end

  def report_index_dropdown_option(report_type, division = nil)
    label = division.nil? ? "Choose Division" : division.name
    value =
      if division.nil?
        ""
      else
        send("#{report_type}_reports_path", division_id: division.id)
      end

    content_tag(
      :option,
      label,
      value: value,
      selected: division.nil?
    )
  end

  def report_index_dropdown(report_type)
    divisions_shown =
      if current_user.as_super_admin?
        Division.all
      else
        current_user.as_divisions
      end

    content_tag(
      :select,
      onChange: "window.location = event.target.value",
      style: "margin-top: 4px; margin-bottom: 4px;"
    ) do
      permitted_divisions =
        if current_user.as_super_admin?
          Division.all
        else
          current_user.as_divisions
        end

      report_index_dropdown_option(report_type) +
        permitted_divisions.map do |division|
          report_index_dropdown_option(
            report_type,
            division
          )
        end.join.html_safe
    end
  end

  def self.included_entities(specialization, divisions, entity)
    if divisions.length == 1
      specialization.send(entity).in_divisions(divisions)
    else
      specialization.send(entity)
    end.reject do |entity|
      !entity.show_waittimes? ||
        if entity.respond_to?(:unavailable_for_a_while?)
          entity.unavailable_for_a_while?
        end
    end
  end
end
