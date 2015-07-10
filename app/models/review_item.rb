class ReviewItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable
  include Archivable

  belongs_to :item, :polymorphic => true

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
    ActiveSupport::JSON.encode params
  end

  def self.decode(params)
    ActiveSupport::JSON.decode params
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

  def creator
    User.safe_find whodunnit
  end

  def active?
    !archived?
  end

  def safe_user
    User.safe_find(
      self.whodunnit,
      UnknownUser
    )
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
