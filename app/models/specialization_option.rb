class SpecializationOption < ActiveRecord::Base
  include PaperTrailable

  attr_accessible :specialization,
    :owner,
    :content_owner,
    :division,
    :is_new,
    :open_to_type_key,
    :open_to_sc_category,
    :show_specialist_categorization_1,
    :show_specialist_categorization_2,
    :show_specialist_categorization_3,
    :show_specialist_categorization_4,
    :show_specialist_categorization_5,
    :specialization_id,
    :division_id,
    :hide_from_division_users

  belongs_to :specialization, touch: true
  belongs_to :owner, class_name: "User"
  belongs_to :content_owner, class_name: "User"
  belongs_to :division
  belongs_to :open_to_sc_category, class_name: "ScCategory"

  def self.for_divisions(divisions)
    where("specialization_options.division_id IN (?)", divisions.map(&:id))
  end

  def self.is_new
    where("specialization_options.is_new = (?)", true)
  end

  DEFAULT_TAB_OPTIONS = StrictHash.new(
    1 => :specialists,
    2 => :clinics,
    3 => :content_category
  )

  def open_to_type
    DEFAULT_TAB_OPTIONS[open_to_type_key]
  end

  def open_to_id
    option_to_type == :content_category ? open_to_sc_category_id : nil
  end
end
