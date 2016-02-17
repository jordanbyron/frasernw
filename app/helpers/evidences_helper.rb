module EvidencesHelper

  def show_evidence?(evidence)
    evidence.present? && (current_user.as_admin_or_super? || ENV['LEVEL_OF_EVIDENCE'].to_b)
  end
end
