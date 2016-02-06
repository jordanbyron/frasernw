module EvidencesHelper

  def show_evidence?(evidence)
    evidence.present? && (current_user_is_admin? || ENV['LEVEL_OF_EVIDENCE'].to_b)
  end
end
