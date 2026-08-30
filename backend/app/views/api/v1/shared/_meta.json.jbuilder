# frozen_string_literal: true

json.meta do
    json.page paginated.current_page
    json.limit paginated.limit_value
    json.total paginated.total_count
    json.total_pages paginated.total_pages
end
