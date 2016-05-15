class ReviewItem < ActiveRecord::Base
  include Noteable
  include Historical

  # we only want archived
  PAPER_TRAIL_IGNORED_ATTRIBUTES = [
    :base_object,
    :object,
    :item_type,
    :item_id,
    :created_at,
    :updated_at,
    :id,
    :edit_source_type,
    :edit_source_id
  ]
  include PaperTrailable
  include Archivable

  belongs_to :item, polymorphic: true

  STATUS_UPDATES = 0
  STATUS_NO_UPDATES = 1

  STATUS_HASH = {
    STATUS_UPDATES => "Updated",
    STATUS_NO_UPDATES => "No Changes",
  }

  def no_updates?
    status == STATUS_NO_UPDATES
  end

  def self.encode(params)
    ActiveSupport::JSON.encode(params).safe_for_javascript
  end

  def self.decode(params)
    ActiveSupport::JSON.decode(params)
  end

  def encode(params)
    self.class.encode params
  end

  def decode(params)
    self.class.decode params
  end

  def transformed_base_object(parent)
    encode form_data_matcher(parent).new(
      decoded_base_object,
      parent
    ).exec.to_hash
  end

  def transformed_review_object(parent)
    encode form_data_matcher(parent).new(
      decoded_review_object,
      parent
    ).exec.to_hash
  end

  def form_data_matcher(parent)
    "FormDataMatcher::#{parent.class.name}".constantize
  end

  def decoded_base_object
    decode self.base_object
  end

  def decoded_review_object
    decode self.object
  end

  def label
    "#{item.name} (Review Item)"
  end

  def set_edit_source!(current_user, secret_token_id)
    if current_user.authenticated?
      self.edit_source_id = current_user.id
      self.edit_source_type = "User"
    else
      self.edit_source_id = secret_token_id
      self.edit_source_type = "SecretToken"
    end
  end

  def secret_edit?
    edit_source.is_a?(SecretToken)
  end

  def edit_source
    if edit_source_id.present? && edit_source_type.present?
      edit_source_type.constantize.where(id: edit_source_id).first || DeletedUser.new
    else
      # review items before new secret token system was created
      SecretEditor.new
    end
  end

  def editor
    if secret_edit?
      edit_source.recipient_user
    else
      edit_source
    end
  end
  alias_method :creator, :editor

  def active?
    !archived?
  end

  class << self
    def for_specialist(specialist)
      where("item_type = ? AND item_id = ?", 'Specialist', specialist.id)
    end

    def for_clinic(clinic)
      where("item_type = ? AND item_id = ?", 'Clinic', clinic.id)
    end
  end
end
