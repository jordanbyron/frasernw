Time::DATE_FORMATS.merge!(
   :datetime_military => '%Y-%m-%d %H:%M',
   :datetime          => '%Y-%m-%d %I:%M%P',
   :time              => '%I:%M%P',
   :time_military     => '%H:%M%P',
   :datetime_short    => '%m/%d %I:%M',
   :day      => lambda { |time| time.strftime("%A, %b #{time.day.ordinalize}") },
   :day_with_year      => lambda { |time| time.strftime("%A, %b #{time.day.ordinalize}, %Y") },
   :day_short      => lambda { |time| time.strftime("%a, %b #{time.day.ordinalize}") },
   :day_short_with_year      => lambda { |time| time.strftime("%a, %b #{time.day.ordinalize}, %Y") },
   :date_with_year => lambda {|time| time.strftime("%b #{time.day.ordinalize}, %Y") }
)