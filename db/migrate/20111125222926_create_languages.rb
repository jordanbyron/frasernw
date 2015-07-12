class CreateLanguages < ActiveRecord::Migration
    def change
        create_table :languages do |t|
            t.string :name

            t.timestamps
        end

        Language.reset_column_information
        Language.create :name => "English"
    end
end
