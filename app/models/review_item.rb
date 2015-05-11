class ReviewItem < ActiveRecord::Base
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

  class << self
    def active
      includes(:item).where(:archived => false)
    end

    def archived
      includes(:item).where(:archived => true)
    end

    def for_specialist(specialist)
      where("item_type = ? AND item_id = ?", 'Specialist', specialist.id)
    end

    def for_clinic(clinic)
      where("item_type = ? AND item_id = ?", 'Clinic', clinic.id)
    end
  end
end
