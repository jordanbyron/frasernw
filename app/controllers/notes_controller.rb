# Polymorphic endpoints!
class NotesController < ApplicationController
  def index
    authorize! :index, Note

    noteable_klass = params[:noteable_type].constantize
    noteable       = noteable_klass.find params[:noteable_id]
    @note          = noteable.notes.build
    @notes         = noteable.persisted_notes
  end

  def create
    authorize! :create, Note

    note_params = params[:note].
      slice(:noteable_id, :noteable_type, :user_id, :content)

    noteable_klass = note_params[:noteable_type].constantize
    noteable       = noteable_klass.find note_params[:noteable_id]

    note = noteable.notes.build
    note.user = current_user
    note.content = note_params[:content]

    if Validate::Note.exec(note)
      note.save
    else
      raise "Invalid"
    end

    redirect_params = note_params.slice(:noteable_id, :noteable_type)
    redirect_to notes_path(redirect_params)
  end

  def destroy
    @note = Note.find params[:id]
    authorize! :destroy, @note
    @note.destroy

    redirect_params = {
      noteable_id: @note.noteable_id,
      noteable_type: @note.noteable_type
    }
    redirect_to notes_path(redirect_params)
  end
end
