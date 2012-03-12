class AddAttachmentFormToReferralForm < ActiveRecord::Migration
  def change
    create_table :referral_forms do |t|
      t.string  :referrable_type
      t.integer :referrable_id
      t.string  :description
      t.string :form_file_name
      t.string :form_content_type
      t.integer :form_file_size
      t.datetime :form_updated_at
      
      t.timestamps
    end
  end
end
