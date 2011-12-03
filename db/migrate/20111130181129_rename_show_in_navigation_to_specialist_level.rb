class RenameShowInNavigationToSpecialistLevel < ActiveRecord::Migration
    def change
        rename_column :procedures, :show_in_navigation, :specialization_level
    end
end
