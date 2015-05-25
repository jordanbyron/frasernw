module Metrics
  class FeedbackMetrics

    attr_accessor :table

    def initialize(*args)
      options = args.extract_options!
      # options[] defines which table columns to use.
      # (all: true) uses all tables


      table = Array.new

      FeedbackItem.all.each do |feedback_item|

        feedback_item_row = Hash.new
        feedback_item_row[:id]                    = feedback_item.id
        feedback_item_row[:feedback]              = feedback_item.feedback
        feedback_item_row[:item_type]             = feedback_item.item_type
        feedback_item_row[:item_id]               = feedback_item.item_id
        feedback_item_row[:division_id_of_item]   = if feedback_item.item.present? && feedback_item.item.divisions.present?
                                                       feedback_item.item.divisions.map{|s| s.id}.join(",")
                                                     else
                                                      ""
                                                     end
        feedback_item_row[:division_name_of_item] = if feedback_item.item.present? && feedback_item.item.divisions.present?
                                                      feedback_item.item.try(:divisions).map { |d| d.name  }.join(", ")
                                                    else
                                                      ""
                                                    end
        feedback_item_row[:created_at]            = feedback_item.created_at
        feedback_item_row[:updated_at]            = feedback_item.updated_at
        feedback_item_row[:archived]              = feedback_item.archived
        table << feedback_item_row
      end
      @table = table
    end

    def as_csv
      CSVReport::ConvertHashArray.new(self.table).exec
    end

    def to_csv_file
      CSVReport::Service.new("reports/feedback_item_metrics.csv", self.as_csv).exec
    end
  end
end