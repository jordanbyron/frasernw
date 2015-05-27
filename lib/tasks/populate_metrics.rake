visitor_accounts [:division_id, :user_type_key, :path]
  - min 1 session
visitor_account [:division_id, :user_type_key]
  - min 5 sessions
  - min 10 sessions
page_views [:division_id, :user_type_key, :path]
sessions [:division_id, :user_type_key, :path]
average_session_duration [:division_id, :user_type_key]
average_page_view_duration [:division_id, :user_type_key]
