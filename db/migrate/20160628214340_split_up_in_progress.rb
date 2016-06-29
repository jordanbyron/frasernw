class SplitUpInProgress < ActiveRecord::Migration
  def up
    add_column :specialization_options,
      :hide_from_own_users,
      :boolean,
      default: false

    add_column :specialization_options,
      :hide_own_entries,
      :boolean,
      default: false

    SpecializationOption.
      where(in_progress: true).
      update_all(hide_from_own_users: true, hide_own_entries: true)

    remove_column :specialization_options, :in_progress
  end
end
