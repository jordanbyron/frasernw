class FindBadReviews < ServiceObject
  def call
    sheets = comprimised_review_items.uniq do |review_item|
      review_item.item
    end.group_by do |review_item|
      review_item.item.divisions.last.name
    end.map do |division, review_items|
      {
        title: division,
        header_row: ["Profile Link", "Name"],
        body_rows: review_items.map do |review_item|
          [
            "https://pathwaysbc.ca#{CustomPathHelper.duck_path(review_item.item)}",
            review_item.item.label
          ]
        end
      }
    end

    QuickSpreadsheet.call(file_title: "changes_to_rereview", sheets: sheets)
  end

  def comprimised_review_items
    ReviewItem.
      where(
        "created_at >= (?) AND created_at < (?)",
        Date.new(2016, 1, 19),
        Date.new(2016, 7, 13)
      ).to_a.
      reject do |item|
        @base_object = item.decoded_base_object
        @review_object = item.decoded_review_object

        if item.item_type == "Specialist"
          matches{|object| object["specialist"]["patient_can_book_mask"]} &&
            matches{|object| object["specialist"]["referral_form_mask"]} &&
            matches do |object|
              object["specialist"]["specialist_offices_attributes"].map do |key, value|
                value["location_is"]
              end
            end
        else
          matches{|object| object["clinic"]["patient_can_book_mask"]} &&
            matches{|object| object["clinic"]["referral_form_mask"]} &&
            matches do |object|
              object["clinic"]["clinic_locations_attributes"].map do |key, value|
                value["wheelchair_accessible_mask"]
              end
            end &&
            matches do |object|
              object["clinic"]["clinic_locations_attributes"].map do |key, value|
                value["location_is"]
              end
            end
        end
      end
  end

  def matches
    yield(@base_object) == yield(@review_object)
  end
end
