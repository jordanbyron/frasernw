module GenerateClinicsAndSpecialistsSpreadsheet
  class << self

    # Written for specific report requirements:
    # - Clinics and Specialists with status_mask "not_responded?".
    def did_not_answer

      clinics = Clinic.where(status_mask: [3,nil])
      specialists = Specialist.where(status_mask: [7,nil])

      not_responded_clinics = []
      not_responded_specialists = []
      
      clinics.each do |clinic|
        clinic_categorization = 
        clinic_row = [
          clinic.id,
          clinic.name,
          clinic_categorization(clinic),
          clinic.status_mask
        ]
        not_responded_clinics.push(clinic_row)
      end

      specialists.each do |specialist|
        specialist_row = [
          specialist.id,
          specialist.name,
          specialist_categorization(specialist),
          specialist.status_mask
        ]
        not_responded_specialists.push(specialist_row)
      end

      print_content = {
        not_responded_clinics: not_responded_clinics,
        not_responded_specialists: not_responded_specialists
      }
      print_spreadsheet(print_content)
      
    end

    private

    def clinic_categorization(clinic)
      case clinic.categorization_mask
      when 1 then
        "Responded to survey"
      when 2 then
        "Not responded to survey"
      when 3 then
        "Purposely not yet surveyed"
      end
    end

    def specialist_categorization(specialist)
      case specialist.categorization_mask
      when 1 then
        "Responded to survey"
      when 2 then
        "Not responded to survey"
      when 3 then
        "Only works out of hospitals or clinics"
      when 4 then
        "Purposely not yet surveyed"
      when 5 then
        "Only accepts referrals through hospitals or clinics"
      end
    end

    def print_spreadsheet(print_content)
      sheets = []
      print_content.each do |title, rows|
        sheet = {
            title: title.to_s.gsub(/_/, " ").capitalize,
            header_row: ["ID","Name","Categorization","Status_mask"],
            body_rows: rows
          }
        sheets.push(sheet)
      end
      spreadsheet = {
        file_title: [caller[0][/`.*'/][1..-2].
          to_s, "_clinics_and_specialists"].
          join(""),
        sheets: sheets
      }
      QuickSpreadsheet.call(spreadsheet)
    end

  end
end
