module GenerateHistory
  module Annotations
    def annotations
      target.notes.each do |note|
        HistoryNode.new(
          target: target,
          user: note.user,
          datetime: note.created_at,
          verb: :annotated,
          content: note.content
        )
      end
    end
  end
end
