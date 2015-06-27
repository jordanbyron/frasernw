module Noteable
  extend ActiveSupport::Concern
  included do
    has_many :notes, :as => :noteable
  end

  def persisted_notes
    notes.select {|note| note.persisted?}
  end
end
