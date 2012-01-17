class AddBillingToSpecialist < ActiveRecord::Migration
  def change
    add_column :specialists, :billing_number, :integer
  end
end
