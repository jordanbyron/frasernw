module AttributeHelper
  def human_attribute_value(model_klass, attribute, value)
    return 'Yes' if value == true
    return 'No' if value == false
    begin
      I18n.translate("#{model_klass.i18n_scope}.values.#{model_klass.model_name.i18n_key}.#{attribute}.#{value}", raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      value
    end
  end
end
