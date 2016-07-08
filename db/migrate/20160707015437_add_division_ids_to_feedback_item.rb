class AddDivisionIdsToFeedbackItem < ActiveRecord::Migration
  def change
    rename_column :feedback_items, :item_id, :target_id
    rename_column :feedback_items, :item_type, :target_type

    add_column :feedback_items, :freeform_email, :string
    add_column :feedback_items, :freeform_name, :string

    add_column :feedback_items,
      :archiving_division_ids,
      :text,
      array: true,
      default: []

    add_column :divisions, :general_feedback_owner_id, :integer

    Division.all.each do |division|
      division.update_attributes(
        general_feedback_owner_id: division.specialization_options.first(&:owner).id
      )
    end
  end
end
