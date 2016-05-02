class SpecializationOption < ActiveRecord::Base

  attr_accessible :specialization,
    :owner,
    :content_owner,
    :division,
    :in_progress,
    :is_new,
    :open_to_type,
    :open_to_sc_category,
    :show_specialist_categorization_1,
    :show_specialist_categorization_2,
    :show_specialist_categorization_3,
    :show_specialist_categorization_4,
    :show_specialist_categorization_5

  belongs_to :specialization, touch: true
  belongs_to :owner, class_name: "User"
  belongs_to :content_owner, class_name: "User"
  belongs_to :division
  belongs_to :open_to_sc_category, class_name: "ScCategory"

  scope :complete, -> { where(in_progress: false) }

  def self.for_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    where("specialization_options.division_id IN (?)", division_ids)
  end

  def self.for_divisions_and_specializations(divisions, specializations)
    division_ids = divisions.map{ |d| d.id }
    specialization_ids = specializations.map{ |s| s.id }
    where(
      "specialization_options.division_id IN (?) "\
      "AND specialization_options.specialization_id IN (?)",
      division_ids,
      specialization_ids
    )
  end

  def self.not_in_progress_for_divisions_and_specializations(divisions, specializations)
    division_ids = divisions.map{ |d| d.id }
    specialization_ids = specializations.map{ |s| s.id }
    where(
      "specialization_options.division_id IN (?) "\
      "AND specialization_options.specialization_id IN (?) "\
      "AND in_progress = (?)",
      division_ids,
      specialization_ids,
      false
    )
  end

  def self.is_new
    where("specialization_options.is_new = (?)", true)
  end

  def open_to_sc_category?
    Rails.logger.info("1")
    open_to_sc_category.present? &&
    open_to_sc_category.
      all_sc_items_for_specialization_in_divisions(specialization, [division]).
      length > 0
  end

  def open_to
    if open_to_type == OPEN_TO_SPECIALISTS
      "specialists"
    elsif open_to_type == OPEN_TO_CLINICS
      "clinics"
    elsif open_to_sc_category?
      open_to_sc_category.id
    else
      "specialists"
    end
  end

  def specialist_categorization_hash
    categorization_hash = {}
    if show_specialist_categorization_1?
      categorization_hash[1] = Specialist::CATEGORIZATION_LABELS[1]
    end
    if show_specialist_categorization_2?
      categorization_hash[2] = Specialist::CATEGORIZATION_LABELS[2]
    end
    if show_specialist_categorization_3?
      categorization_hash[3] = Specialist::CATEGORIZATION_LABELS[3]
    end
    if show_specialist_categorization_4?
      categorization_hash[4] = Specialist::CATEGORIZATION_LABELS[4]
    end
    if show_specialist_categorization_5?
      categorization_hash[5] = Specialist::CATEGORIZATION_LABELS[5]
    end
    categorization_hash
  end

  OPEN_TO_SPECIALISTS = 1
  OPEN_TO_CLINICS = 2
  OPEN_TO_SC_CATEGORY = 3

  OPEN_TO_HASH = {
    OPEN_TO_SPECIALISTS => "Specialists",
    OPEN_TO_CLINICS => "Clinics",
    OPEN_TO_SC_CATEGORY => "Content Category"
  }

  include PaperTrailable
end
