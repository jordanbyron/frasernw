class GenerateHistory
  class Annotations < Base
    def exec
      return [] unless target.is_a? Noteable

      target.persisted_notes.map {|note| node(note) }
    end

    def node(note)
      HistoryNode.new(
        target: target,
        user: note.user,
        datetime: note.created_at,
        verb: :annotated,
        note: note.content
      )
    end
  end
end
