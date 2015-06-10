# Returns list of Feedback items
# e.g. Metrics::FeedbackMetrics.new("reports/dialogue").to_csv_file

module Metrics
  class FeedbackMetrics
    attr_reader :folder_path

    def initialize(folder_path)
      @folder_path = folder_path
    end

    def table
      @table ||= FeedbackItem.all.inject([]) do |memo, feedback_item|
        memo << row_from_feedback(feedback_item)
      end
    end


    def row_from_feedback(feedback_item)
      row = Hash.new
      row[:id]                    = feedback_item.id
      row[:feedback]              = feedback_item.feedback
      row[:item_type]             = feedback_item.item_type
      # row[:item_id]               = feedback_item.item_id
      row[:division_id_of_item]   = begin
        if feedback_item.item.present? && feedback_item.item.divisions.present?
          feedback_item.item.divisions.map{|s| s.id}.join(",")
        else
          ""
        end
      end
      row[:division_name_of_item] = begin
        if feedback_item.item.present? && feedback_item.item.divisions.present?
          feedback_item.item.try(:divisions).map { |d| d.name  }.join(", ")
        else
          ""
        end
      end
      row[:created_at]            = feedback_item.created_at
      row[:updated_at]            = feedback_item.updated_at
      row[:archived]              = feedback_item.archived

      row
    end


    def as_csv
      CSVReport::ConvertHashArray.new(self.table).exec
    end

    def to_csv_file
      CSVReport::Service.new("#{folder_path}/feedback_item_metrics-#{DateTime.now.to_date.iso8601}.csv", self.as_csv).exec
    end
  end
end