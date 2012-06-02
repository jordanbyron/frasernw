class UpdateFavorites < ActiveRecord::Migration
  def change
    remove_column :favorites,   :specialist_id
    add_column    :favorites,   :favoritable_id,    :integer
    add_column    :favorites,   :favoritable_type,  :string
    add_index     :favorites,   [:favoritable_id, :favoritable_type]
  end
end
