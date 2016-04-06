class GenerateUsersSpreadsheet

  def generate_fnw_users_spreadsheet

    fnw_users = User.joins(:divisions).where(type_mask: [1,4,6,7], divisions: {id: 1})

    pending_users = []
    inactive_users = []
    other_users = []

    fnw_users.each do |user|

      last_logged_in =  !user.last_request_at.nil? ? user.last_request_at.to_s : "Never"

      status =
        if user.pending?
          "Pending"
        elsif !user.active?
          "Inactive"
        else
          "Other"
        end

      type =
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

      user_row = [user.id, user.name, user.email, last_logged_in, status, type]

      if user.pending?
        pending_users.push(user_row)
      elsif !user.active?
        inactive_users.push(user_row)
      else
        other_users.push(user_row)
      end
    end      

    QuickSpreadsheet.call(
            file_title: "fnw_users",
            sheets: [
              {
                title: "Pending Users",
                header_row: ["ID","Name","Email","Last Logged-In", "Status", "Type"],
                body_rows: pending_users
              },
              {
                title: "Inactive Users",
                header_row: ["ID","Name","Email","Last Logged-In", "Status", "Type"],
                body_rows: inactive_users
              },
              {
                title: "Other Users",
                header_row: ["ID","Name","Email","Last Logged-In", "Status", "Type"],
                body_rows: other_users
              }
            ]
          )
    
  end
end
