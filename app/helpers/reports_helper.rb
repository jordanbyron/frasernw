module ReportsHelper
  def report_row(
    report_type,
    divisional: false,
    restricted: false,
    manual_label: nil
  )
    if can?(:view_report, report_type)
      content_tag :tr do
        report_index_label(report_type, manual_label) +
        report_index_scope_options(report_type, divisional, restricted)
      end
    else
      ""
    end
  end

  def self.included_entities(specialization, divisions, entity)
    if divisions.one?
      specialization.send(entity).in_divisions(divisions)
    else
      specialization.send(entity)
    end.select do |entity|
      entity.show_waittimes? && (
        !entity.respond_to?(:unavailable_for_a_while?) ||
          !entity.unavailable_for_a_while?
        )
    end
  end

  private

  def report_index_label(report_type, manual_label)
    content_tag :td do
      if manual_label.nil?
        report_type.to_s.split("_").map(&:capitalize).join(" ")
      else
        manual_label
      end
    end
  end

  def report_index_scope_options(report_type, divisional, restricted)
    system_wide_link =
      if current_user.as_super_admin? || !restricted
        link_to(
          "System-wide",
          send("#{report_type}_reports_path")
        )
      else
        ""
      end
    conjunction =
      if system_wide_link.present? && divisional
        content_tag(
          :span,
          " or ",
          style: "margin-left: 10px; margin-right: 10px;"
        )
      else
        ""
      end
    divisional_link =
      if divisional
        report_index_division_selector(report_type)
      else
        ""
      end

    content_tag :td do
      (system_wide_link + conjunction + divisional_link).html_safe
    end
  end

  def permitted_divisions
    if current_user.as_super_admin?
      Division.all
    else
      current_user.as_divisions
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

  def report_index_division_selector(report_type)
    if permitted_divisions.one?
      link_to(permitted_divisions.first.name, send(
        "#{report_type}_reports_path",
        division_id: permitted_divisions.first.id
      ))
    else
      content_tag(
        :select,
        onChange: "window.location = event.target.value",
        style: "margin-top: 4px; margin-bottom: 4px;"
      ) do
        report_index_dropdown_option(report_type) +
          permitted_divisions.map do |division|
            report_index_dropdown_option(
              report_type,
              division
            )
          end.join.html_safe
      end
    end
  end
end
