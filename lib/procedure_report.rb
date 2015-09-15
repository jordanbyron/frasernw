class ProcedureReport
  def self.exec
    filename = "cancer_procedures"
    folder_path = Rails.root.join("reports", "procedures")
    FileUtils.ensure_folder_exists folder_path

    table = Procedure.all.select do |procedure|
      procedure.name.match(/(cancer|oncology|tumour)/i)
    end.map do |procedure|
      [ procedure.id, procedure.name ]
    end

    CSVReport::Service.new(
      "#{folder_path}/#{filename}.csv",
      table
    ).exec
  end
end
