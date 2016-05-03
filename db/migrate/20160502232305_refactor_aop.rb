class RefactorAop < ActiveRecord::Migration
  def up
    create_table :areas_of_practice do |t|
      t.string :name
      t.string :ancestry

      t.timestamps
    end

    create_table :specialization_areas_of_practice do |t|
      t.boolean :assumed_specialist
      t.boolean :assumed_clinic
      t.boolean :focused
      t.boolean :mapped
      t.boolean :collect_specialist_wait_time
      t.boolean :collect_clinic_wait_time
      t.integer :area_of_practice_id

      t.timestamps
    end

    create_table :performs_areas_of_practice do |t|
      t.integer :provider_id
      t.string :provider_type
      t.string :investigation
      t.integer :area_of_practice_id
      t.integer :waittime_mask
      t.integer :lagtime_mask
    end

    migrate_procedure_specializations(ProcedureSpecialization.arrange, nil)
    check_procedure_specializations!
  end

  def migrate_procedure_specializations(procedure_specializations_tree, ancestry_scope)
    procedure_specializations_tree.each do |procedure_specialization, children|
      existing_aop = AreaOfPractice.where(
        name: procedure_specialization.procedure.name
        ancestry: ancestry_scope
      ).first

      if !existing_aop.present?
        aop = AreaOfPractice.create(
          name: procedure_specialization.procedure.name,
          ancestry: ancestry_scope
        )
      else
        aop = existing_aop
      end

      AreaOfPracticeSpecialization.create(
        assumed_specialist: procedure_specialization.assumed_specialist?,
        assumed_clinic: procedure_specialization.assumed_clinic?,
        focused: procedure_specialization.focused?,
        mapped: procedure_specialization.mapped?,
        collect_specialist_wait_time: procedure_specialization.specialist_wait_time
        collect_clinic_wait_time: procedure_specialization.clinic_wait_time
        area_of_practice_id: aop.id
      )

      [
        [ Focus, "Clinic", "clinic_id" ],
        [ Capacity, "Specialist", "specialist_id" ],
      ].each do |config|
        config[0].
          where(procedure_specialization_id: procedure_specialization.id).
          each do |link|
            PerformsAreaOfPractice.create(
              provider_id: link.send(config[2]),
              provider_type: config[1],
              investigation: link.investigation,
              area_of_practice_id: aop.id,
              waittime_mask: link.waittime_mask,
              lagtime_mask: link.lagtime_mask
            )
          end
      end

      childrens_ancestry_scope =
        if ancestry_scope == nil
          aop.id.to_s
        else
          "#{ancestry_scope}/#{aop.id}"
        end

      migrate_procedure_specializations(
        procedure_specialization.children,
        childrens_ancestry_scope
      )
    end
  end

  def check_procedure_specializations!
    Specialization.each do |specialization|
      areas_of_practice = AreaOfPractice.
        joins(:area_of_practice_specializations).
        where(area_of_practice_specialization: specialization.id).
        arrange

      compare_trees!(
        specialization.procedure_specializations.arrange,
        areas_of_practice
      )
    end
  end

  def compare_trees!(procedure_specializations, areas_of_practice)
    if !(procedure_specializations.keys.map(&:procedure).map(&:name).sort ==
      areas_of_practice.map(&:name))
      binding.pry
    end

    procedure_specializations.keys.each do |procedure_specialization|
      matching_aop = areas_of_practice.keys.find do |aop|
        aop.name == procedure_specialization.procedure.name
      end

      compare_trees!(
        procedure_specialization.children,
        matching_aop.children
      )
    end
  end

  def down
  end
end
