# Polymorphic endpoints!
class NotesController < ApplicationController
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
    end

    redirect_params = {
      item_id: note_params[:noteable_id],
      item_type: note_params[:noteable_type]
    }

    if params[:redirect] === "target_history"
      redirect_to history_path(redirect_params)
    else
      redirect_to CustomPathHelper.duck_path(noteable)
    end
  end

  def update
    @note = Note.find(params[:id])

    authorize! :update, @note

    @note.update_attributes(content: params[:content])

    render json: {
      raw_content: @note.content,
      content: BlueCloth.new(@note.content).to_html
    }
  end

  def destroy
    @note = Note.find params[:id]
    authorize! :destroy, @note
    @note.destroy

    redirect_params = {
      item_id: @note.noteable_id,
      item_type: @note.noteable_type
    }
    redirect_to history_path(redirect_params)
  end
end
