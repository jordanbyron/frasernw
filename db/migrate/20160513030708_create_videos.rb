class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :video_url
      t.attachment :video_clip

      t.timestamps
    end
  end
end
