class ChangeSpecializationLevelToDefaultToTrue < ActiveRecord::Migration
    def change
        change_column :procedures, :specialization_level, :boolean, :default => true
    end
end
