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

    def low_info_specialists_and_clinics
      clinics = Clinic.select do |clinic|
        ([3,nil].include? clinic.status_mask) ||
          ([2, 3, nil].include? clinic.categorization_mask)
      end
      specialists = Specialist.select do |specialist|
        ([7,nil].include? specialist.status_mask) ||
          ([2, 4, nil].include? specialist.categorization_mask)
      end

      low_info_clinics = []
      low_info_specialists = []

      clinics.each do |clinic|
        clinic_categorization =
        clinic_row = [
          clinic.id,
          clinic.name,
          clinic_categorization(clinic),
          Clinic::STATUS_HASH[clinic.status_mask]
        ]
        low_info_clinics.push(clinic_row)
      end

      specialists.each do |specialist|
        specialist_row = [
          specialist.id,
          specialist.name,
          specialist_categorization(specialist),
          Specialist::STATUS_HASH[specialist.status_mask]
        ]
        low_info_specialists.push(specialist_row)
      end

      printing_body = {
        low_info_clinics: low_info_clinics,
        low_info_specialists: low_info_specialists
      }
      printing_header = ["ID","Name","Categorization","Status"]
      print_spreadsheet(printing_body, printing_header)
    end

    # Status "moved away", "permanently unavailable", or
    # "indefinitely unavailable"
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

    # Status "unavailable_between" or "indefinitely unavailable"
    def specialists_temporarily_or_indefinitely_unavailable
      specialists = Specialist.where(status_mask: [6,8])

      indefinitely_unavailable_specialists = []
      temporarily_unavailable_specialists = []

      specialists.select do |specialist|
        # 'responded to survey', 'not responded'
        [1, 2].include?(specialist.categorization_mask)
      end.each do |specialist|
        specialist_row = [
          specialist_id_link(specialist.id),
          specialist.name
        ]
        if specialist.status_mask === 8
          indefinitely_unavailable_specialists.push(specialist_row)
        elsif specialist.status_mask === 6
          temporarily_unavailable_specialists.push(specialist_row)
        else
          raise "Something went wrong"
        end
      end

      printing_body = {
        temporarily_unavailable_specialists: temporarily_unavailable_specialists,
        indefinitely_unavailable_specialists: indefinitely_unavailable_specialists
      }
      printing_header = ["ID","Name"]
      print_spreadsheet(printing_body, printing_header)
    end

    # - FNW users who are type: "GP Office," "Locum," "Resident," or "Other."
    #   (Excludes "Specialist Office", "Clinic", "Hospitalist",
    #   "Nurse Practitioner", or "Unit Clerk.")
    # - "Pending," "Inactive," and "Other" -status accounts split by worksheet.
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
      printing_header = ["ID","Name","Email","Last Logged-In","Status","Type"]
      print_spreadsheet(printing_body, printing_header)
    end

    def clinic_owners_without_specialists
      users_to_review =
        User.where(agree_to_toc: true, active: true).select do |user|
          user.controlled_clinics.any?
        end.reject do |user|
          user.controlled_clinics.any? do |clinic|
            (clinic.attendances.any? do |attendance|
              attendance.specialist_id.present? ||
                attendance.freeform_firstname.present?
            end || clinic.specialists_with_offices_in.any?)
          end || user.controlled_specialists.any?
        end

      users_rows = []
      users_to_review.each do |user|
        user_row = [
          user.divisions.first.name,
          user.id,
          user.name,
          user.role
        ]
        user.controlled_clinics.each do |clinic|
          user_row.push(clinic.id)
          user_row.push(clinic.name)
        end
        users_rows.push(user_row)
      end

      printing_body = {
        users_owning_only_unattended_clinics: users_rows
      }
      printing_header = [
        "User Divisions",
        "User ID",
        "User name",
        "User role",
        "Clinic ID",
        "Clinic name"
      ]
      print_spreadsheet(printing_body, printing_header)
    end

    def content_without_pageviews
      content_with_views = EntityPageViews.call(
        start_month_key: 201601,
        end_month_key: Month.current.to_i,
        division_id: 0
      ).select{|row| row[:resource] == :content_items}.
        map{|row| row[:id] }

      content_without_views = ScItem.
        where("id NOT IN (?)", content_with_views).
        includes(:division)

      provincial_division_id = Division.provincial.id

      bodies = content_without_views.
        group_by(&:division).
        map{|division, items| [ division.name, items.map{|item| [item.id, item.title] } ] }.
        sort_by{|pair| pair[0] == "Provincial" ? 0 : 1 }.
        to_h

      print_spreadsheet(bodies, [ "ID", "Title" ])
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
