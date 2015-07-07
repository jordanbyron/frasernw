class GenerateHistory
  class Archived < Base
    def exec
      return [] unless target.is_a? Archivable
      return [] unless archived_version.present?

      [
        HistoryNode.new(
          target: target,
          user: archived_version.safe_user,
          datetime: archived_version.created_at,
          verb: :archived
        )
      ]
    end

    def archived_version
      @archived_version ||= target.versions.select do |version|
        version.archiving_item?
      end.last
    end
  end
end
