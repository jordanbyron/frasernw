module Analytics
  module Populator
    # Populates a table with data for a given metric, for a given month
    class Frame
      def self.add_frame(options)
        new(options).exec
      end

      attr_reader :frame, :table, :row_populator, :options

      def initialize(options)
        @frame = options[:frame]
        @options = options
        @row_populator = Analytics::Populator::Row
      end

      def exec
        puts "populating for frame #{options}"
        frame.rows.each do |row|
          row_populator.add_row(
            row,
            metric: options[:metric],
            min_sessions: options[:min_sessions],
            month: options[:month]
          )
        end
      end
    end
  end
end
