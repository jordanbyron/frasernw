module Validate
  class Note
    def self.exec(note)
      note.user.present? && note.noteable.present? && note.content.present?
    end
  end
end
