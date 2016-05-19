class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :link
      t.string :title
      t.attachment :video_clip

      t.timestamps
    end
  end
end
