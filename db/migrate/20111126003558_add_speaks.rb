class AddSpeaks < ActiveRecord::Migration
    def change
        create_table :speaks do |t|
            t.integer :specialist_id
            t.integer :language_id

            t.timestamps
        end
    end
end
