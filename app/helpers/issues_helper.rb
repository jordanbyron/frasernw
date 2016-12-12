module IssuesHelper

  def issue_comment(note)
    react_component(
      "IssueComment",
      {
        id: note.id,
        author_name: note.author_name,
        current_user_id: current_user.id,
        creator_id: note.user_id,
        created_at: note.created_at.to_s(:datetime_military),
        content: BlueCloth.new(note.content).to_html,
        raw_content: note.content
      }
    )
  end
end
