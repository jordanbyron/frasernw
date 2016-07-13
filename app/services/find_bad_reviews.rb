class FindBadReviews < ServiceObject
  def call
    comprimised_review_items.count
  end

  def comprimised_review_items
    ReviewItem.
      where("created_at > (?)", Date.new(2016, 1, 19)).
      to_a.
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
