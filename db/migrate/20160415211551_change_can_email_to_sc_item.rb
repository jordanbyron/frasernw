class ChangeCanEmailToScItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :can_email, :boolean

    ScItem.all.each do |sc|
      sc.update_columns can_email: (sc.type_mask == 1 && sc.can_email_link?)
                                || (sc.type_mask == 3 && sc.can_email_document?)
    end

    remove_column :sc_items, :can_email_document
    remove_column :sc_items, :can_email_link
  end
end
