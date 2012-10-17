class AddCanEmailDocumentToScItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :can_email_document, :boolean, :default => false
    add_column :sc_items, :can_email_link, :boolean, :default => true
  end
end
