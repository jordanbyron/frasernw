class CreateSpecializationOptions < ServiceObject
  attribute :division, Division

  def call
    Specialization.all.each do |specialization|
      CreateSpecializationOption.call(
        division: division,
        specialization: specialization
      )
    end
  end

  class CreateSpecializationOption < ServiceObject
    attribute :division, Division
    attribute :specialization, Specialization

    def call
      division.
        specialization_options.
        find_or_initialize_by(specialization_id: specialization.id).
        update_attributes(copied_attributes.merge(owner_attributes))
    end

    def template_option
      @template_option ||= Division.find(1).
        specialization_options.
        find_by_specialization_id(specialization.id)
    end

    def copied_attributes
      template_option.attributes.slice(*COLUMNS_TO_COPY)
    end

    def owner_attributes
      [ :owner, :content_owner ].map do |owner_type|
        value = begin
          if template_option.send(owner_type) && template_option.send(owner_type).super_admin?
            template_option.send(owner_type)
          else
            User.super_admin.first
          end
        end

        [ owner_type, value ]
      end.to_h
    end

    COLUMNS_TO_COPY = [
      :in_progress,
      :open_to_type,
      :open_to_sc_category_id,
      :is_new,
      :show_specialist_categorization_1,
      :show_specialist_categorization_2,
      :show_specialist_categorization_3,
      :show_specialist_categorization_4,
      :show_specialist_categorization_5
    ]
  end
end
