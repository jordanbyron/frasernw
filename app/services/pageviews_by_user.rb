class PageviewsByUser < ServiceObject
  attribute :start_month, Month
  attribute :end_month, Month
  attribute :division_id, Integer

  def call
    matched_users.map do |row|
      {
        id: row[:user].id,
        name: row[:user].name,
        pageViews: row[:page_views]
      }
    end
  end

  def division
    @division =
      if division_id == 0
        nil
      else
        Division.find(division_id)
      end
  end

  def filtered_users
    users.select do |user|
      if !division.nil?
        user.divisions.include?(division) && !user.admin_or_super?
      else
        !user.admin_or_super?
      end
    end
  end

  def matched_users
    filtered_users.map do |user|
      {
        user: user,
        page_views: matched_row(user)[:page_views]
      }
    end
  end

  def matched_row(user)
    api_response.find{|row| row[:user_id] == user.id.to_s }
  end

  def api_response
    @api_response ||= Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: start_month.start_date,
      end_date: end_month.end_date,
      dimensions: [:user_id]
    })
  end

  def users
    @users ||= User.
      includes(:divisions).
      where(id: api_response.map{|row| row[:user_id] })
  end
end
