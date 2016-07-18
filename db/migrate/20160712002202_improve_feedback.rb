class ImproveFeedback < ActiveRecord::Migration
  def change
    rename_column :feedback_items, :item_id, :target_id
    rename_column :feedback_items, :item_type, :target_type

    add_column :feedback_items, :freeform_email, :string
    add_column :feedback_items, :freeform_name, :string

    remove_column :divisions, :primary_contact_id

    add_column :feedback_items,
      :archiving_division_ids,
      :text,
      array: true,
      default: []

    FeedbackItem.all.each do |item|
      if item.targeted? && item.target.nil? && !item.archived?
        item.update_attribute(:archived, true)
      end
    end
  end
end
