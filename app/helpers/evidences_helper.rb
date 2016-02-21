module EvidencesHelper

  def show_evidence?(evidence)
    evidence.present? && (current_user.as_admin_or_super? || ENV['LEVEL_OF_EVIDENCE'].to_b)
  end

  def evidence_label(evidence)
    link_to evidence.label, evidences_path
  end

  def evidence_tooltip_text(evidence)
    if evidence.quality_of_evidence.present?
      "Level of Evidence: #{evidence.level} <br> #{evidence.quality_of_evidence} Quality".html_safe
    else
      "Level of Evidence: (LOE=#{evidence.level})"
    end
  end
end
