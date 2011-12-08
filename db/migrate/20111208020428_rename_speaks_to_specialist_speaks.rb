class RenameSpeaksToSpecialistSpeaks < ActiveRecord::Migration
  def change
    rename_table( :speaks, :specialist_speaks )
  end
end
