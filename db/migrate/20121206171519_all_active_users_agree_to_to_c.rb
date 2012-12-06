class AllActiveUsersAgreeToToC < ActiveRecord::Migration
  def change
    User.all.reject{|u| u.pending?}.each do |user|
      if !user.update_attributes(:agree_to_toc => true)
        puts "#{user.name} couldn't be marked as agree_to_toc"
      end
    end
  end
end
