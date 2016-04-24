class ChangeCanEmailToScItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :can_email, :boolean

    ScItem.all.each do |sc_item|
      can_email = (sc_item.type_mask == 1 && sc_item.can_email_link?) ||
        (sc_item.type_mask == 3 && sc_item.can_email_document?)

      sc_item.update_columns(can_email: can_email)
    end

    remove_column :sc_items, :can_email_document
    remove_column :sc_items, :can_email_link
  end
end
