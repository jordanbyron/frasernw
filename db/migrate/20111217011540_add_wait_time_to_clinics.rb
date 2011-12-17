class AddWaitTimeToClinics < ActiveRecord::Migration
  
  def migrate_values(migrate_class)
    
    migrate_class.find(:all).each do |c|
      next if c.waittime_old == "" or c.wait_uom_old == ""
      
      days = case c.wait_uom_old
        when "days" then c.waittime_old
        when "weeks" then c.waittime_old * 7
        when "months" then c.waittime_old * 7 * 4
        else 0
      end
      
      #this matches with our options for clinic / specialist waittime_mask, assuming a month is four weeks
      c.waittime_mask = case days
        when 0..7 then 1
        when 8..14 then 2
        when 15..28 then 3
        when 29..56 then 4
        when 57..112 then 5
        when 113..168 then 6
        when 169..224 then 7
        when 225..336 then 8
        when 337..504 then 9
        else 10
      end
      
      c.save
    end
    
    migrate_class.find(:all).each do |c|
      next if c.lagtime_old == "" or c.lag_uom_old == ""
      
      days = case c.lag_uom_old
        when "days" then c.lagtime_old
        when "weeks" then c.lagtime_old * 7
        when "months" then c.lagtime_old * 7 * 4
        else 0
      end
      
      #this matches with our options for clinic / specialist lagtime_mask, assuming a month is four weeks
      c.lagtime_mask = case days
        when 0..7 then 2
        when 8..14 then 3
        when 15..28 then 4
        when 29..56 then 5
        when 57..112 then 6
        when 113..168 then 7
        when 169..224 then 8
        when 225..336 then 9
        when 337..504 then 10
        else 11
      end
      
      c.save
    end
  end
  
  def change
    add_column :clinics, :waittime_mask, :integer
    rename_column :clinics, :waittime, :waittime_old
    rename_column :clinics, :wait_uom, :wait_uom_old
    
    add_column :clinics, :lagtime_mask, :integer
    rename_column :clinics, :lagtime, :lagtime_old
    rename_column :clinics, :lag_uom, :lag_uom_old
    
    migrate_values(Clinic)
    
    add_column :specialists, :waittime_mask, :integer
    rename_column :specialists, :waittime, :waittime_old
    rename_column :specialists, :wait_uom, :wait_uom_old
    
    add_column :specialists, :lagtime_mask, :integer
    rename_column :specialists, :lagtime, :lagtime_old
    rename_column :specialists, :lag_uom, :lag_uom_old
    
    migrate_values(Specialist)
  end
end