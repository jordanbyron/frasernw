module GenerateUsersSpreadsheet
  class << self
    def fnw

      fnw_users = User.joins(:divisions).where(type_mask: [1,4,6,7], divisions: {id: 1})

      pending_users = []
      inactive_users = []
      other_users = []

      fnw_users.each do |user|
        user_row = [user.id, user.name, user.email, last_logged_in(user), status(user), type(user)]

        if user.pending?
          pending_users.push(user_row)
        elsif !user.active?
          inactive_users.push(user_row)
        else
          other_users.push(user_row)
        end
      end

      print_content = {pending_users: pending_users, inactive_users: inactive_users, other_users: other_users}
      print_spreadsheet(print_content)
      
    end

    private

    def type(user)
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

    def status(user)
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

    def print_spreadsheet(print_content)
      sheets = []
      print_content.each do |title, rows|
        sheet = {
            title: title.to_s.gsub(/_/, " ").capitalize,
            header_row: ["ID","Name","Email","Last Logged-In", "Status", "Type"],
            body_rows: rows
          }
        sheets.push(sheet)
      end
      spreadsheet = {
        file_title: [caller[0][/`.*'/][1..-2].to_s, "_users"].join(""),
        sheets: sheets
      }
      QuickSpreadsheet.call(spreadsheet)
    end

  end
end
