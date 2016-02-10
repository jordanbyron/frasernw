class UpdateScItemSharing < ServiceObject
  attribute :is_shared, Axiom::Types::Boolean
  attribute :division, Division
  attribute :sc_item, ScItem
  attribute :current_user, User

  def call
    existing_record =
      DivisionDisplayScItem.where(sc_item_id: sc_item.id, division_id: division.id).first

    if current_user.super_admin? || current_user.divisions.include?(division)
      if is_shared && !existing_record.present?
        DivisionDisplayScItem.create(sc_item_id: sc_item.id, division_id: division.id)
      elsif !is_shared && existing_record.present?
        existing_record.destroy
      end

      true
    else
      false
    end
  end

end
