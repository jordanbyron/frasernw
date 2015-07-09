class BuildReviewItemNote
  attr_reader :params, :review_item, :user

  def initialize(attrs)
    @params = attrs[:params]
    @review_item = attrs[:review_item]
    @user = attrs[:current_user]
  end

  def exec
    if note_content.present?
      new_note.assign_attributes(content: note_content)
      new_note.save
    end
  end

  def new_note
    @new_note ||= review_item.build_new_note!(user)
  end

  def note_content
    params[:review_item_note]
  end
end
