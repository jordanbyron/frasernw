module VersionsHelper
  def whodunnit_name(version)
     # ? User.find(version.whodunnit).username : 'unknown'
    if version.whodunnit.to_i.to_s == version.whodunnit
      name_for(User.find(version.whodunnit))
    elsif version.whodunnit == "MOA"
      version.whodunnit
    else
      'unknown'
    end
  end

  def activity_badge(version)
    klass = version.item_type.downcase
              .gsub('attachment', 'file')
              .gsub('privilege', 'hospital privileges')
              .gsub('procedure', 'area of practice')
              .gsub('capacity', 'area of practice')
              .gsub('office', 'office details')
    content_tag :span, class: ["type", klass] do
      klass.titlecase
    end
  end

  def translate_changes(version, attribute, changeset)
    return 'Yes' if changeset == true
    return 'No' if changeset == false
    begin
      I18n.translate("#{version.item_type.constantize.i18n_scope}.values.#{version.item_type.constantize.model_name.i18n_key}.#{attribute}.#{changeset}", raise: I18n::MissingTranslationData)
    rescue I18n::MissingTranslationData
      changeset
    end
  end

  def link_to_item(version)
    begin
      case version.item_type
      when "Specialist"
        if version.event == "create"
          link_to version.item.name, specialist_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, specialist_path(version.item_id)
        else
          link_to version.reify.name, show_version_path(version)
        end
      when "Privilege", "Capacity", "Attendance", "SpecialistAddress", "SpecialistSpeaks"
        if version.event == "create"
          link_to version.item.specialist.name, specialist_path(version.item.specialist)
        elsif %w(update destroy).include? version.event
          link_to version.reify.specialist.name, specialist_path(version.reify.specialist)
        end
      when "Clinic" 
        if version.event == "create"
          link_to version.item.name, clinic_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, clinic_path(version.item_id)
        end
      when "Focus", "ClinicAddress", "ClinicSpeaks", "ClinicHealthcareProvider"
        if version.event == "create"
          link_to version.item.specialist.name, clinic_path(version.item.clinic)
        elsif %w(update destroy).include? version.event
          link_to version.reify.specialist.name, clinic_path(version.reify.clinic)
        end
      when "Specialization"
        if version.event == "create"
          link_to version.item.name, specialization_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, specialization_path(version.item_id)
        end
      when "Procedure"
        if version.event == "create"
          link_to version.item.name, procedure_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, procedure_path(version.item_id)
        end
      when "Hospital"
        if version.event == "create"
          link_to version.item.name, hospital_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, hospital_path(version.item_id)
        end
      when "HospitalAddress"
        if version.event == "create"
          link_to version.item.specialist.name, hospital_path(version.item.clinic)
        elsif %w(update destroy).include? version.event
          link_to version.reify.specialist.name, hospital_path(version.reify.clinic)
        end
      when "Language"
        if version.event == "create"
          link_to version.item.name, language_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, language_path(version.item_id)
        end
      when "HealthcareProvicer"
        if version.event == "create"
          link_to version.item.name, healthcare_provider_path(version.item_id)
        elsif version.event == "update"
          link_to version.reify.name, healthcare_provider_path(version.item_id)
        end
      end
    rescue
      "This item was deleted after this change was made."
    end
  end
  
  def association_details(version)
    #TODO: this isn't clear it works at all
    return if not version.item
    case version.item_type
    when "Privilege"
      if not version.item.hospital
        return
      elsif version.event == "create"
        version.item.hospital.name
      elsif %w(update destroy).include? version.event
        version.reify.hospital.name
      end
    when "Capacity"
      if not version.item.procedure
        return
      elsif version.event == "create"
        version.item.procedure.name
      elsif %w(update destroy).include? version.event
        version.reify.procedure.name
      end
    when "SpecialistSpeak", "ClinicSpeak"
      if not version.item.language
        return
      elsif version.event == "create"
        version.item.language.name
      elsif %w(update destroy).include? version.event
        version.reify.language.name
      end
    when "SpecialistAddress", "ClinicAddress", "HospitalAddress"
      if not version.item.address
        return
      elsif version.event == "create"
        version.item.address.name
      elsif %w(update destroy).include? version.event
        version.reify.address.name
      end
    end
    rescue
      return
  end
end
