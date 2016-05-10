module GenerateSpreadsheet
  class << self

    def specialists_and_clinics_not_responded

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

      printing_body = {
        not_responded_clinics: not_responded_clinics,
        not_responded_specialists: not_responded_specialists
      }
      printing_header = ["ID","Name","Categorization","Status_mask"]
      print_spreadsheet(printing_body, printing_header)
      
    end

    # Status "moved away", "permanently unavailable", or "indefinitely unavailable"
    def specialists_moved_away_or_unavailable
      specialists = Specialist.where(status_mask: [8,9,10])

      moved_away_specialists = []
      indefinitely_unavailable_specialists = []
      permanently_unavailable_specialists = []

      specialists.each do |specialist|
        specialist_row = [
          specialist_id_link(specialist.id),
          specialist.name
        ]
        if specialist.status_mask === 8
          indefinitely_unavailable_specialists.push(specialist_row)
        elsif specialist.status_mask === 9
          permanently_unavailable_specialists.push(specialist_row)
        elsif specialist.status_mask === 10
          moved_away_specialists.push(specialist_row)
        else
          raise "Something went wrong"
        end
      end

      printing_body = {
        moved_away_specialists: moved_away_specialists,
        permanently_unavailable_specialists: permanently_unavailable_specialists,
        indefinitely_unavailable_specialists: indefinitely_unavailable_specialists
      }
      printing_header = ["ID","Name"]
      print_spreadsheet(printing_body, printing_header)

    end

    # - FNW users who are type: "GP Office," "Locum," "Resident," or "Other."
    #   (Excludes "Specialist Office", "Clinic", "Hospitalist", "Nurse Practitioner",
    #     or "Unit Clerk.")
    # - "Pending," "Inactive," and "Other" -status accounts, split into worksheets.
    # - Columns: "id", "name", "email", "last_logged_in", "status", and "type."
    def fnw_users

      fnw_users = User.
        joins(:divisions).
        where(type_mask: [1,4,6,7], divisions: { id: 1 })

      pending_users = []
      inactive_users = []
      other_users = []

      fnw_users.each do |user|
        user_row = [
          user.id,
          user.name,
          user.email,
          last_logged_in(user),
          user_status(user),
          user_type(user)
        ]

        if user.pending?
          pending_users.push(user_row)
        elsif !user.active?
          inactive_users.push(user_row)
        else
          other_users.push(user_row)
        end
      end

      printing_body = {
        pending_users: pending_users,
        inactive_users: inactive_users,
        other_users: other_users
      }
      printing_header = ["ID","Name","Email","Last Logged-In", "Status", "Type"]
      print_spreadsheet(printing_body, printing_header)
      
    end

    private

    def specialist_id_link(id)
      Spreadsheet::Link.new "pathwaysbc.ca/specialists/#{id}", id.to_s
    end

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

    def user_type(user)
      case user.type_mask
      when 1 then
        "GP Office"
      when 4 then
        "Other"
      when 6 then
        "Locum"
      when 7 then
        "Resident"
      end    
    end

    def user_status(user)
      if user.pending?
        "Pending"
      elsif !user.active?
        "Inactive"
      else
        "Other"
      end      
    end

    def last_logged_in(user)
      !user.last_request_at.nil? ? user.last_request_at.to_s : "Never"
    end

    def print_spreadsheet(body, header)
      sheets = []
      body.each do |title, rows|
        sheet = {
            title: title.to_s.gsub(/_/, " ").capitalize,
            header_row: header,
            body_rows: rows
          }
        sheets.push(sheet)
      end
      spreadsheet = {
        file_title: caller[0][/`.*'/][1..-2].to_s,
        sheets: sheets
      }
      QuickSpreadsheet.call(spreadsheet)
    end

  end
end
