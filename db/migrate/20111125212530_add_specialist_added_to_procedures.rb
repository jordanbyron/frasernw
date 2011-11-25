class AddSpecialistAddedToProcedures < ActiveRecord::Migration
  def change
      add_column :procedures, :show_in_navigation, :boolean
      Procedure.find(:all).each do |p|
          p.show_in_navigation = true
          p.save
      end
  end
end
