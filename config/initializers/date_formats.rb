Time::DATE_FORMATS.merge!(
   :date              => '%Y-%m-%d',                                                                  # 2013-03-23
   :datetime_military => '%Y-%m-%d %H:%M',                                                            # 2013-03-23 13:36
   :datetime          => '%Y-%m-%d %I:%M%P',                                                          # 2013-03-23 01:36pm
   :time              => '%I:%M%P',                                                                   # 01:36pm
   :time_military     => '%H:%M%P',                                                                   # 13:36pm
   :datetime_short    => '%m/%d %I:%M',                                                               # 03/23 01:36
   :day      => lambda { |time| time.strftime("%A, %b #{time.day.ordinalize}") },                     # Saturday, Mar 23rd
   :day_with_year      => lambda { |time| time.strftime("%A, %b #{time.day.ordinalize}, %Y") },       # Saturday, Mar 23rd, 2013
   :day_short      => lambda { |time| time.strftime("%a, %b #{time.day.ordinalize}") },               # Sat, Mar 23rd
   :day_short_with_year      => lambda { |time| time.strftime("%a, %b #{time.day.ordinalize}, %Y") }, # Sat, Mar 23rd, 2013
   :date_with_year => lambda {|time| time.strftime("%b #{time.day.ordinalize}, %Y") }                 # Mar 23rd, 2013
)