class UpdateScItemBorrowing < ServiceObject
  attribute :is_borrowed, Axiom::Types::Boolean
  attribute :division_id, Integer
  attribute :sc_item, ScItem

  def call
    existing_record =
      DivisionDisplayScItem.
        where(sc_item_id: sc_item.id, division_id: division_id).
        first
    if is_borrowed && !existing_record.present?
      DivisionDisplayScItem.create(
        sc_item_id: sc_item.id,
        division_id: division_id
      )
    elsif !is_borrowed && existing_record.present?
      existing_record.destroy
    end

    true
  end
end
