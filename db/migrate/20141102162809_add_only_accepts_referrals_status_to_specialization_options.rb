class AddOnlyAcceptsReferralsStatusToSpecializationOptions < ActiveRecord::Migration
  def change
    add_column :specialization_options, :show_specialist_categorization_1, :boolean, :default => true
    add_column :specialization_options, :show_specialist_categorization_2, :boolean, :default => true
    add_column :specialization_options, :show_specialist_categorization_3, :boolean, :default => true
    add_column :specialization_options, :show_specialist_categorization_4, :boolean, :default => true
    add_column :specialization_options, :show_specialist_categorization_5, :boolean, :default => false

    SpecializationOption.all.reject{ |so| so.specialization.id != 55 }.each do |so|
      #family practice
      so.show_specialist_categorization_5 = true
      so.save
    end
  end
end
