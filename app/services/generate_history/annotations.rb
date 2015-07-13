class GenerateHistory
  class Annotations < Base
    def exec
      return [] unless target.is_a? Noteable

      from_notes_records + from_admin_notes_field
    end

    def from_notes_records
      target.persisted_notes.map {|note| node(note) }
    end

    def node(note)
      HistoryNode.new(
        target: target,
        user: (note.user || UnknownUser.new),
        datetime: note.created_at,
        verb: :annotated,
        note: note.content
      )
    end

    def from_admin_notes_field
      if !target.respond_to? :admin_notes || target.admin_notes == ""
        return []
      else
        [
          HistoryNode.new(
            target: target,
            user: migrating_user,
            datetime: DateTime.new(2015, 7, 13),
            verb: :migrated_annotation,
            note: target.admin_notes.gsub("\n", "(newline) ")
          )
        ]
      end
    end

    # Brian Gracie
    def migrating_user
      @migrating_user ||= User.find(3243)
    end
  end
end
