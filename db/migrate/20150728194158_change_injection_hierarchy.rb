class ChangeInjectionHierarchy < ActiveRecord::Migration
  AFFECTED_SPECIALIZATIONS = [
    "Orthopedics",
    "Rehabilitation Medicine",
    "Internal Medicine",
    "Rheumatology",
    "Pain Management",
    "Sports Medicine",
    "Nurse Practitioner",
    "Family Practice"
  ]

  BODY_PARTS = [
    "Ankle",
    "Elbow",
    "Hand",
    "Hip",
    "Knee",
    "Shoulder",
    "Wrist"
  ]
  def up
    # Test prep
    # Record the clinics that have "<body part>" > "injection"
    # after the migration, we'll make sure they have
    # "joint injection" > "<body part>"

    clinics = BODY_PARTS.inject({}) do |memo, body_part|
      ids = Clinic.
        with_ps_with_ancestry("#{body_part} > Injection").
        map(&:id)

      memo.merge(
        body_part => ids
      )
    end

    # Atm, specialists who specialize only in "injection"
    # at the data level implicitly also specialize in "body_part"
    # at the view level.  Let's make this explicit at the data level
    # before doing the migration, so there aren't suprising profile
    # changes

    BODY_PARTS.each do |body_part|
      AddParentProcedureSpecialization.exec(
        klasses: [Clinic, Specialist],
        hierarchy: "#{body_part} > Injection"
      )

      # Check
      implicit = Clinic.
        with_ps_with_ancestry("#{body_part} > Injection").
        map(&:id).
        sort

      explicit = Clinic.
        with_ps_ancestry("#{body_part} > Injection").
        map(&:id).
        sort

      raise unless implicit == explicit
    end

    AddParentProcedureSpecialization.exec(
      klasses: [Clinic, Specialist],
      hierarchy: "Knee > Viscosupplementation"
    )

    # Now do the actual migration

    # Create our new joint injection procedure
    joint_injection_procedure = Procedure.create(
      name: "Joint Injection",
      specialization_level: true
    )

    # First we want to rename the "Injection" procedures to the parent
    # "<Body Part>"
    # We'll stash the IDs of those procedures so we can find the
    # parent procedure specializations later
    affected_procedure_ids =
      Procedure.where(name: "Injection").inject([]) do |ids, procedure|
        # Check to make sure parent procedure is the same for all proc spec
        # This migration strategy won't work otherwise..
        parent_procedure_ids =
          procedure.
          procedure_specializations.
          map(&:parent).
          map(&:procedure).
          map(&:id)
        raise unless parent_procedure_ids.uniq.length == 1

        # rename to the first parent procedure
        procedure.update_attributes(
          name: procedure.procedure_specializations.first.parent.procedure.name
        )

        ids << procedure.id
      end

    # Reassign ancestry for the procedure specializations that used to
    # have "Injection" as their procedure name, and now have "<body part>"
    # Instead of "<body part>" as the parent, they should have
    # "Joint Injection"
    AFFECTED_SPECIALIZATIONS.each do |specialization_name|
      specialization =
        Specialization.where(name: specialization_name).first
      raise unless specialization.present?

      joint_injection_procedure_specialization =
        specialization.procedure_specializations.create(
          ancestry: nil,
          procedure_id: joint_injection_procedure.id,
          mapped: true,
          classification: 1,
          clinic_wait_time: false,
          specialist_wait_time: false
        )

      affected_procedure_ids.each do |id|
        procedure_specialization =
          specialization.
            procedure_specializations.
            where(procedure_id: id).
            first

        # might not be present in this specialization
        next unless procedure_specialization.present?

        procedure_specialization.update_attributes(
          ancestry: joint_injection_procedure_specialization.id.to_s
        )
      end

      viscosupplementation_procedure_specialization =
        specialization.
          procedure_specializations.
          find{ |ps| ps.procedure.name == "Viscosupplementation" }

      next unless viscosupplementation_procedure_specialization.present?

      knee_procedure_specialization =
        joint_injection_procedure_specialization.
        children.
        find{ |ps| ps.procedure.name == "Knee" }

      viscosupplementation_procedure_specialization.update_attributes(
        ancestry: knee_procedure_specialization.id.to_s
      )
    end

    # Test to make sure clinics that had "<body part>" > "injection"
    # before the migration have "joint injection" > "<body part>" now
    clinics.each do |body_part, clinic_ids|
      new_ids = Clinic.
        with_ps_with_ancestry("Joint Injection > #{body_part}").
        map(&:id)

      raise unless new_ids.sort == clinic_ids.sort
    end
  end

  def down
    # not implemented!
  end
end
