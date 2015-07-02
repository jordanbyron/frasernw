# Wraps an event that has happened to the target in order to provide a consistent interface for presentation

class HistoryNode < OpenStruct
  # {
  #   user: current_user,
  #   verb: :annotated,
  #   target: ReviewItem.last,
  #   datetime: DateTime.now,
  #   content: "This is a note"
  # }

  # add 'parent'?/ 'on'?

  def to_s
    "#{user_name} #{verb_label} #{target_label} on #{date_label}"
  end

  def user_name
    user.name
  end

  def date_label
    datetime.to_date.to_s
  end

  def verb_label
    verb.to_s.gsub("_", " ")
  end

  def target_label
    target.numbered_label
  end

  def has_content?
    content.present?
  end
end
